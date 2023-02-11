#!/bin/bash
PRG="$0"

# Makes the file $1 writable by the group $serviceGroup.
function makeFileWritable {
   local filename="$1"
   touch "$filename" || return 1
   return 0; }

# Returns 0 if the process with PID $1 is running.
function checkProcessIsRunning {
   local pid="$1"
   if [ -z "$pid" -o "$pid" == " " ]; then return 1; fi
   if [ ! -e /proc/"$pid" ]; then return 1; fi
   return 0; }

# Returns 0 if the process with PID $1 is our Java service process.
function checkProcessIsOurService {
   local pid="$1"
   if [ "$(ps -p "$pid" --no-headers -o comm)" != "$javaCommand" ]; then return 1; fi
   grep -q --binary -F "$javaCommandLineKeyword" /proc/"$pid"/cmdline
   if [ $? -ne 0 ]; then return 1; fi
   return 0; }

# Returns 0 when the service is running and sets the variable $pid to the PID.
function getServicePID {
   if [ ! -f "$pidFile" ]; then return 1; fi
   pid="$(<"$pidFile")"
   checkProcessIsRunning "$pid" || return 1
   checkProcessIsOurService "$pid" || return 1
   return 0; }

function startServiceProcess {
   
   rm -f "$pidFile"
   makeFileWritable "$pidFile" || return 1
   makeFileWritable "$serviceLogFile" || return 1
   cmd="nohup $javaCommandLine &> $serviceLogFile &"
   eval "$cmd" || return 1
   echo $! &> "$pidFile"
   pid="$(<"$pidFile")"
   sleep 1
   if checkProcessIsRunning "$pid"; then :; else
      echo -ne "\n$serviceName start failed, see logfile."
      return 1
   fi
   return 0; }

function stopServiceProcess {
   kill "$pid" || return 1
   for ((i=0; i<maxShutdownTime*10; i++)); do
      checkProcessIsRunning "$pid"
      if [ $? -ne 0 ]; then
         rm -f "$pidFile"
         return 0
         fi
      sleep 1
      done
   echo -e "\n""$serviceName"" did not terminate within ""$maxShutdownTime"" seconds, sending SIGKILL..."
   kill -s KILL "$pid" || return 1
   local killWaitTime=15
   for ((i=0; i<killWaitTime*10; i++)); do
      if ! checkProcessIsRunning "$pid"; then
         rm -f "$pidFile"
         return 0
         fi
      sleep 0.1
      done
   echo "Error: $serviceName could not be stopped within $maxShutdownTime+$killWaitTime seconds!"
   return 1; }

function startService {
   
   if ! getServicePID; then echo -n "$serviceName is already running"; RETVAL=0; return 0; fi
   echo -n "Starting $serviceName "
   if ! startServiceProcess; then RETVAL=1; echo "failed"; return 1; fi
   echo "started PID=$pid"
   RETVAL=0
   return 0; }

function stopService {
   if ! getServicePID; then echo -n "$serviceName is not running"; RETVAL=0; echo ""; return 0; fi
   echo -n "Stopping $serviceName   "
  # ps aux | grep SQLOffloadStarter | grep -v grep | awk '{print$2}' | xargs kill -9
   if ! stopServiceProcess; then RETVAL=1; echo "failed"; return 1; fi
   echo "stopped PID=$pid"
   RETVAL=0
   return 0; }

function checkServiceStatus {
   echo -n "Checking for $serviceName:   "
   if getServicePID; then
	echo "running PID=$pid"
	RETVAL=0
   else
	echo "stopped"
	RETVAL=3
   fi
   return 0; }

function main {
   RETVAL=0
   case "$1" in
      start)                                               # starts the Java program as a Linux service
         startService
         ;;
      stop)                                                # stops the Java program service
         stopService
         ;;
      restart)                                             # stops and restarts the service
         stopService && startService
         ;;
      status)                                              # displays the service status
         checkServiceStatus
         ;;
      *)
         echo "Usage: $0 {start|stop|restart|status}"
         exit 1
         ;;
      esac
   return $RETVAL
}

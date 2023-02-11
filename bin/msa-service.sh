#!/bin/bash
# ------------------------------------------------------------------------------------------
#  Script for service startup
#
# File Information
# 	Name: msa-service.sh
# 	Version: 1.0
# 	Created: 2023/02/11 18:49
# 	Author: Eusuf Kanchwala
# ------------------------------------------------------------------------------------------

# Generic messages for script
MESSAGE_EXIT_SCRIPT="Exiting msa-service.sh script with exit status :";
MESSAGE_RESOLVE_ISSUE="Please resolve issues manually and re-execute script."

# Function - Prints the error messages and exits the script with error status
exit_as_error() {
    EXIT_STATUS=$1;
    echo "${MESSAGE_RESOLVE_ISSUE}";
    echo "${MESSAGE_EXIT_SCRIPT} ${EXIT_STATUS}";
    exit ${EXIT_STATUS};
}

# Identify Microservice installation directory
echo "Identifying Microservice installation directory";
PRG="$0"
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  # Resolve links - $0 may be a soft-link
  if expr "$link" : '.*/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
PRGDIR=`dirname "$PRG"`

# Setting APP_HOME variable
APP_HOME=`cd "$PRGDIR/.." ; pwd`

. ${APP_HOME}/bin/env.sh
. ${APP_HOME}/bin/utils.sh

#----------------------------------------------------------------------------------------------
# Step 1: Manage service
#----------------------------------------------------------------------------------------------
SERVICE="Chicago";
echo "Calling $1 service on -> ${SERVICE}"
javaCommand="java"                                         # name of the Java launcher without the path
javaExe="$JAVA_HOME/bin/$javaCommand"                      # file name of the Java application launcher executable

FINAL_RETURN_VALUE=-1
for i in `seq 1 ${NUMBER_OF_CHICAGO_SERVICE_INSTANCES}`
do
	export SERVICE_NAME="chicago_$CHICAGO_REST_PORT";
	
	serviceLogFile="${APP_HOME}/logs/${SERVICE_NAME}-startup.log"
	
	pidFile="${APP_RUN}/${SERVICE_NAME}.pid"
		
	JAVA_OPTS=" -XX:+UseParallelOldGC -XX:LargePageSizeInBytes=4m -XX:+PrintGCDetails -XX:+UseCompressedOops -XX:+PrintGCDateStamps -verbosegc -Xloggc:${APP_RUN}/gc_${SERVICE_NAME}.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${APP_RUN}/ -Dspring.security.enabled=false -Dmanagement.security.enabled=false -Dsecurity.basic.enabled=false -Xmx2048m -DAPP_LOG=${APP_LOG}/ -Dlogging.config=${APP_HOME}/conf/logback.xml -Dspring.application.name=${SERVICE} -Dserver.port=${CHICAGO_REST_PORT} -cp "
		
	javaArgs=" $JAVA_OPTS"

	jarsCommon="${APP_HOME}/lib/*:${APP_CONNECTORS_DIR}/*: ${CHICAGO_MAIN_CLASS_NAME} "	
	javaCommandLine="$javaExe $javaArgs $jarsCommon"       # command line to start the Java service application
	echo $javaCommandLine;

	RETURN_VALUE=$( main $1 );
	RETURN_VALUE=`echo $?`
	if [ $RETURN_VALUE -ne 0 ]; then
	   echo "ERROR: Service $SERVICE_NAME returned code $RETURN_VALUE during $1 operation.";
	else
	   FINAL_RETURN_VALUE=0
	   echo "SUCCESS: Service ${SERVICE_NAME} $1 successfully.";
	fi
	
	CHICAGO_REST_PORT="$(( ${CHICAGO_REST_PORT} + 1 ))";
done

exit $FINAL_RETURN_VALUE;

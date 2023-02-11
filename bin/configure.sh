#!/bin/bash
# ------------------------------------------------------------------------------------------
# Configure script for the Chicago service
#
# The script configures Chicago service as per the given user inputs
#
# File Information
# 	Name: configure.sh
# 	Version: 1.0
# 	Created: 2023/02/11 18:49
# 	Author: Eusuf Kanchwala
# ------------------------------------------------------------------------------------------

# Generic messages for script
MESSAGE_EXIT_SCRIPT="Exiting Chicago Chicago configure script with exit status :";
MESSAGE_RESOLVE_ISSUE="Please resolve issues manually and re-execute script."

# Function - Gets an escaped value for a given directory path
get_escaped_value() {
    VALUE=$1;
    ESCAPED_VALUE=${VALUE//\//\\/}
    echo "${ESCAPED_VALUE}";
}

# Function - Prints the error messages and exit the script with error status
exit_as_error() {
    EXIT_STATUS=$1;
    echo "${MESSAGE_RESOLVE_ISSUE}";
    echo "${MESSAGE_EXIT_SCRIPT} ${EXIT_STATUS}";
    exit ${EXIT_STATUS};
}

#--------------------------------------------------------------------------------------------
# Step 1 : Identify Chicago installation directory
# 	If any of the step fails, then return script with exit status as 1
#--------------------------------------------------------------------------------------------
echo "Identifying Chicago installation directory";
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

# Setting APP_INSTALLATION_DIR and APP_HOME variables
APP_INSTALLATION_DIR=`cd "$PRGDIR/.." ; pwd`
APP_HOME=`cd "$PRGDIR/.." ; pwd`

# Validate if the configure.sh file exists using the APP_HOME value
if [ ! -r "${APP_HOME}/bin/configure.sh" ]; then
  # if file does not exits, then exit the configure script with error
  echo "ERROR: Could not identify Chicago installation directory.";
  exit_as_error 1;
fi

# Include Chicago environment variables defined in scripts - 
. ${APP_HOME}/bin/env.sh


#--------------------------------------------------------------------------------------------
# Step 2 : Configure for Chicago services
#--------------------------------------------------------------------------------------------
echo "Configuring for Chicago services"

# Configure Chicago host, Chicago port and database port information for WorkloadMigration services
# Initialize an array for Chicago configurations files
# The files contain configurations related to APP_HOST, PORT and APP_DATABASE_PORT

# Update script permissions for Chicago service
APP_PERMISSIONS_CMD="chmod 755 ${APP_HOME}/bin/*"
echo "Updating script permissions for Chicago service";
if ! ${APP_PERMISSIONS_CMD}; then
	echo "ERROR: Could not update script permissions for Chicago service";
	exit_as_error 2;
fi

mkdir -p ${APP_RUN}
mkdir -p ${APP_LOG}

#--------------------------------------------------------------------------------------------
# Step 3 : Exit script with success
#--------------------------------------------------------------------------------------------
# Print success message and exit with status as 0
echo "Chicago Chicago configured successfully."
echo "${MESSAGE_EXIT_SCRIPT} 0";
exit 0;
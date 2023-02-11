#!/bin/bash
# ------------------------------------------------------------------------------------------
# Environment settings for the Chicago Deployment
#
# Set the required user inputs for services as per the configurations
#
# File Information
# 	Name   : env.sh
# 	Version: 1.0
# 	Created: 2023/02/11 18:49
# 	Author: Eusuf Kanchwala
# ------------------------------------------------------------------------------------------

# if APP_INSTALLATION_DIR is not set, then identify App installation directory
if [ -z "$APP_INSTALLATION_DIR" ]; then
	PRG="$0"
	while [ -h "$PRG" ]; do
		ls=$(ls -ld "$PRG")
		link=$(expr "$ls" : '.*-> \(.*\)$')
		# Resolve links - $0 may be a soft-link
		if expr "$link" : '.*/.*' > /dev/null; then
			PRG="$link"
		else
			PRG=$(dirname "$PRG")/"$link"
		fi
	done
	PRGDIR=$(dirname "$PRG")

	# Setting APP_INSTALLATION_DIR and APP_HOME variables
	APP_INSTALLATION_DIR=$(cd "$PRGDIR/.." || exit ; pwd)
	APP_HOME=$(cd "$PRGDIR/.." || exit ; pwd)
fi

# Set the value of installation directory for Java
export JAVA_HOME=VALUE_JAVA_HOME;

NUMBER_OF_CHICAGO_SERVICE_INSTANCES=1;
CHICAGO_REST_PORT="21001";
APP_RUN="${APP_INSTALLATION_DIR}/run";
APP_LOG="${APP_INSTALLATION_DIR}/log";
APP_CONNECTORS_DIR="${APP_INSTALLATION_DIR}/lib/connectors";
CHICAGO_MAIN_CLASS_NAME="";


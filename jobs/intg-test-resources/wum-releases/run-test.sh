#!/bin/bash

set -o xtrace

INPUTS_DIR=$2

PROP_FILE="${INPUTS_DIR}/deployment.properties"
PRODUCT_GIT_URL=$(grep -w "PRODUCT_GIT_URL" ${PROP_FILE} | cut -d'=' -f2 | cut -d'/' -f3-)
PRODUCT_GIT_BRANCH=$(grep -w "PRODUCT_GIT_BRANCH" ${PROP_FILE} | cut -d'=' -f2)
keyFileLocation=$(grep -w "keyFileLocation" ${PROP_FILE} | cut -d'=' -f2)
WSO2InstanceName=$(grep -w "WSO2InstanceName" ${PROP_FILE} | cut -d'=' -f2 | cut -d"/" -f3)
OperatingSystem=$(grep -w "OS" ${PROP_FILE} | cut -d'=' -f2)
PRODUCT_NAME=$(grep -w "WSO2_PRODUCT" ${PROP_FILE}| cut -d'=' -f2 | cut -d'-' -f1)
PRODUCRT_VERSION=$(grep -w "WSO2_PRODUCT" ${PROP_FILE}| cut -d'=' -f2 | cut -d'-' -f2)

SCRIPT_REPOSITORY=$(grep -w "TEST_SCRIPT_URL" ${PROP_FILE} | cut -d'=' -f2)
SCRIPT_BRANCH=$(grep -w "TEST_SCRIPT_BRANCH" ${PROP_FILE} | cut -d'=' -f2)
SCRIPT_REPOSITORY_NAME=$(echo ${SCRIPT_REPOSITORY} | rev | cut -d'/' -f1 | rev)

NEXUS_SCRIPT_NAME="uat-nexus-settings.xml"
NEXUS_SCRIPT_PATH='/testgrid/testgrid-home/jobs/wso2am-2.1.0-int-test'

GIT_USER=$(grep -w "GIT_WUM_USERNAME" ${PROP_FILE} | cut -d'=' -f2)
GIT_PASS=$(grep -w "GIT_WUM_PASSWORD" ${PROP_FILE} | cut -d'=' -f2)

function log_info(){
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
}

git clone ${SCRIPT_REPOSITORY} -b ${SCRIPT_BRANCH}

if [ ${OperatingSystem} = "Ubuntu" ]; then
    instanceUser="ubuntu"
elif [ ${OperatingSystem} = "CentOS" ]; then
    instanceUser="centos"
else
    instanceUser="ec2-user"
fi

scp -o StrictHostKeyChecking=no -i ${keyFileLocation} ${NEXUS_SCRIPT_PATH}/${NEXUS_SCRIPT_NAME} $instanceUser@${WSO2InstanceName}:/opt/testgrid/workspace/${NEXUS_SCRIPT_NAME}
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyFileLocation} -r ${SCRIPT_REPOSITORY_NAME} $instanceUser@${WSO2InstanceName}:/opt/testgrid/workspace/${SCRIPT_REPOSITORY_NAME}
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${keyFileLocation} $instanceUser@${WSO2InstanceName} "cd /opt/testgrid/workspace/${SCRIPT_REPOSITORY_NAME} && sudo bash run-int-test.sh ${PRODUCT_GIT_URL} ${PRODUCT_GIT_BRANCH} ${PRODUCT_NAME} ${PRODUCRT_VERSION}"
ssh -o StrictHostKeyChecking=no -i ${keyFileLocation} $instanceUser@${WSO2InstanceName} "ls /opt/testgrid/workspace"
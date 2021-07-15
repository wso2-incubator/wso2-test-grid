#----------------------------------------------------------------------------
#  Copyright (c) 2021 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#----------------------------------------------------------------------------
#!/bin/bash

set -o xtrace; set -e

WORKING_DIR=$(pwd)
WSO2_PRODUCT_NAME=$1
WSO2_PRODUCT_VERSION=$2
GITUSER=$3
GITPASS=$4
CFN_PROP_FILE=/opt/testgrid/workspace/cfn-props.properties
ANSIBLE_REPO_NAME=$(echo ANSIBLE_REPO_URL | rev | cut -d'/' -f1 | rev)
DB_PROV_SCRIPT_NAME="provision_db_${WSO2_PRODUCT_NAME}.sh"
DB_PROV_SCRIPT_PATH="${WORKING_DIR}/${DB_PROV_SCRIPT_NAME}"
# get aws properties
DBEngine=$(grep -w "DB_TYPE" ${CFN_PROP_FILE} | cut -d'=' -f2)
DBEngineVersion=$(grep -w "CF_DB_VERSION" ${CFN_PROP_FILE} | cut -d'=' -f2)
JDK=$(grep -w "JDK_TYPE" ${CFN_PROP_FILE} | cut -d'=' -f2)
DBPassword=$(grep -w "CF_DB_PASSWORD" ${CFN_PROP_FILE} | cut -d'=' -f2)
DBUsername=$(grep -w "CF_DB_USERNAME" ${CFN_PROP_FILE} | cut -d'=' -f2)
DBHost=$(grep -w "CF_DB_HOST" ${CFN_PROP_FILE} | cut -d'=' -f2)
DBPort=$(grep -w "CF_DB_PORT" ${CFN_PROP_FILE} | cut -d'=' -f2)
SID=$(grep -w "SID" ${CFN_PROP_FILE} | cut -d'=' -f2)

function log_info(){
    echo "[INFO][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
}

function log_error(){
    echo "[ERROR][$(date '+%Y-%m-%d %H:%M:%S')]: $1"
    exit 1
}

function  install_ansible(){
    apt update
    apt install software-properties-common -y
    apt-add-repository --yes --update ppa:ansible/ansible
    apt update
    apt install ansible -y

    ansible --version
}

log_info "Deploying ansible resources for ${WSO2_PRODUCT_NAME}-${WSO2_PRODUCT_VERSION}"

# install ansible
log_info "Installing Ansible"
install_ansible

# Clone ansible resource repository
log_info "Cloning ${ANSIBLE_REPO_NAME} into ${WORKING_DIR}"
if ! git clone --single-branch https://${GITUSER}:${GITPASS}@ANSIBLE_REPO_URL -b ANSIBLE_REPO_BRANCH; then
    log_error "Failed to clone ${ANSIBLE_REPO_NAME}"
fi
log_info "Successfully cloned ${ANSIBLE_REPO_NAME}"

# copy product pack to ansible
if [ -f /opt/testgrid/workspace/$WSO2_PRODUCT_NAME-$WSO2_PRODUCT_VERSION.zip ]; then
    echo "Updated pack available"
    cp /opt/testgrid/workspace/$WSO2_PRODUCT_NAME-$WSO2_PRODUCT_VERSION.zip ${ANSIBLE_REPO_NAME}/files/packs/$WSO2_PRODUCT_NAME-$WSO2_PRODUCT_VERSION.zip
else
    echo "Updated pack not available."
fi

log_info "Updating ansible resources"
sed -i "s/DB_TYPE/${DBEngine}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/roles/common/tasks/main.yml
sed -i "s/JDK_TYPE/${JDK}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/roles/common/tasks/main.yml
sed -i "s/RDS_PWD/${DBPassword}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/dev/group_vars/*
sed -i "s/RDS_USERNAME/${DBUsername}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/dev/group_vars/*
sed -i "s/DB_ADDRESS/${DBHost}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/dev/group_vars/*
sed -i "s/SID/${SID}/g" ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/dev/group_vars/*

log_info "Running ansible scripts"
cd ${ANSIBLE_REPO_NAME} 
ansible-playbook -i ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/dev ${WORKING_DIR}/${ANSIBLE_REPO_NAME}/site.yml

log_info "Downloading Database provision scripts"
if ! wget https://integration-testgrid-resources.s3.amazonaws.com/db_scripts/${DB_PROV_SCRIPT_NAME}; then
    log_error "Downloading provision scripts failed"
fi
log_info "Successfully downloaded database provision scripts"
chmod +x ${DB_PROV_SCRIPT_NAME}

log_info "Updating Database provision scripts"
sed -i "s/&CF_DB_USERNAME/${DBUsername}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&CF_DB_PASSWORD/${DBPassword}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&CF_DB_HOST/${DBHost}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&CF_DB_PORT/${DBPort}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&CF_DB_NAME/${DBEngine}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&CF_DB_VERSION/${DBEngineVersion}/g" ${DB_PROV_SCRIPT_NAME}
sed -i "s/&PRODUCT_VERSION/${WSO2_PRODUCT_VERSION}/g" ${DB_PROV_SCRIPT_NAME}

bash ${DB_PROV_SCRIPT_NAME}

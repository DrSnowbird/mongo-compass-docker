#!/bin/bash -x

ORGANIZATION=${ORGANIZATION:-openkbs}
PROJECT=${PROJECT:-myproject}
APPLICATION_NAME=${PWD##*/}
APP_VERSION=${APP_VERSION:-1.0.0}

## Base image to build this container
FROM_BASE=${FROM_BASE:-centos:8}
imageTag=${imageTag:-"${ORGANIZATION}/${APPLICATION_NAME}"}

## Docker Registry (Private Server)
#REGISTRY_IMAGE=${REGISTRY_HOST}/${imageTag}
VERSION=${APP_VERSION}-$(date +%Y%m%d)

###################################################
#### ---- Top-level build-arg arguments ----
###################################################
MY_DIR=$(dirname "$(readlink -f "$0")")

###################################################
#### ---- Change this only to use your own ----
###################################################
baseDataFolder="$HOME/data-docker"

###################################################
#### **** Container package information ****
###################################################

## -- transform '-' and space to '_'
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

echo "---------------------------------------------"
echo "---- Print Log for Container for ${imageTag}"
echo "---------------------------------------------"
#sudo docker rm  -f $(docker ps 2>&1 | grep "reasoner-docker" | awk '{print $1}')
sudo docker rm  -f ${instanceName}

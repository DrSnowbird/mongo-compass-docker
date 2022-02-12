#!/bin/bash -x

MY_DIR=$(dirname "$(readlink -f "$0")")

if [ $# -lt 1 ]; then
    echo "Usage: "
    echo "  ${0} [Different tgz Docker Image file]"
    echo "e.g.: "
    echo "  ${0} "
fi

###################################################
#### ---- Change this only to use your own ----
###################################################
ORGANIZATION=openkbs

###################################################
#### **** Container package information ****
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag="${ORGANIZATION}/${DOCKER_IMAGE_REPO}"

###################################################
#### ---- Mostly, you don't need change below ----
###################################################
## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

TGZ_DOCKER_IMAGE=${1:-${instanceName}.tgz}

function restore() {
    if [ ! -s ${TGZ_DOCKER_IMAGE} ]; then
        echo "*** ERROR ***: Can't find image (*.tgz or tar.gz) file: Can't continue! Abort!"
        exit 1
    fi
    gunzip -c ${TGZ_DOCKER_IMAGE} | docker load
    sudo docker images | grep ${TGZ_DOCKER_IMAGE%.tgz}
}

echo "---------------------------------------------"
echo "---- SAVE a Container for ${imageTag}"
echo "---------------------------------------------"

restore



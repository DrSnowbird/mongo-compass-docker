#!/bin/bash -x

MY_DIR=$(dirname "$(readlink -f "$0")")

if [ $# -lt 1 ]; then
    echo "Usage: "
    echo "  ${0} "
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
imageTag=${1:-$imageTag}

IMAGE_NAME=${imageTag%:*}
IMAGE_VERSION=${imageTag#*:}
if [ "$IMAGE_VERSION" = "" ]; then
    # -- patch in the image version
    imageTag="${IMAGE_NAME}:latest"
fi
###################################################
#### ---- Mostly, you don't need change below ----
###################################################
## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

TGZ_DOCKER_IMAGE=${instanceName}.tgz

function save() {
    lookupImage=`sudo docker images  ${imageTag} | grep  ${imageTag} | awk '{print $1}'`
    if [ "$lookupImage" = "" ]; then
	    echo "*** ERROR ***: Can't find Docker image (${imageTag}): Can't continue! Abort!"
        exit 1
    fi
    sudo docker save ${imageTag} | gzip > ${TGZ_DOCKER_IMAGE}
    ls -al ${TGZ_DOCKER_IMAGE}
}

echo "---------------------------------------------"
echo "---- SAVE a Container for ${imageTag}"
echo "---------------------------------------------"

save



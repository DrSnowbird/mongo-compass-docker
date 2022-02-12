#!/bin/bash

MY_DIR=$(dirname "$(readlink -f "$0")")

if [ $# -lt 1 ]; then
    echo "------------- Clean up both Container and Images -------------"
    echo "Usage: "
    echo "  ${0} [<container_shell_command>]"
    echo "e.g.: "
    echo "  ${0} tensorflow-python3-jupyter "
    echo "  ${0} "
    echo "      (empty argument will use default the current git container name to clean up)"
fi

###################################################
#### ---- Change this only to use your own ----
###################################################
ORGANIZATION=openkbs
baseDataFolder="$HOME/data-docker"

###################################################
#### **** Container package information ****
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag="${ORGANIZATION}/${DOCKER_IMAGE_REPO}"

## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

echo "---------------------------------------------"
echo "---- Clean up the Container for ${imageTag}"
echo "---------------------------------------------"

if [ $1 ]; then
    imageTag="$1"
fi

containers=`docker ps -a | grep ${imageTag} | awk '{print $1}' `

if [ $containers ]; then
    docker rm -f $containers
fi

for IMAGE_ID in `docker images -a | grep ${imageTag} | awk '{print $3}' `; do
    children=$(docker images --filter since=${IMAGE_ID} -q)
    if [[ ! $children == *"No such image"* ]]; then
        id=$(docker inspect --format='{{.Id}} {{.Parent}}' $children |cut -d':' -f2|cut -c-12)
        if [ "$id" != "" ]; then
            docker rmi -f $id
        fi
    fi
done



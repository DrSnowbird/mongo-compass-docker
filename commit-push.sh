#!/bin/bash

# Reference: https://docs.docker.com/engine/userguide/containers/dockerimages/

echo "Usage: "
echo "  ${0} <comment> [<repo-name/repo-tag>] [<imageVersion>]"
echo "e.g."
echo "  ${0} \"initial updates\" \"openkbs/docker-project-tempalte\" \"1.0.0\" "
echo ""
echo "-------------------------------------"
echo "-- Make sure you do login first:   --"
echo "-- To login:"
echo "       docker login"
echo "-------------------------------------"
echo

comment=${1:-Update with the latest changes}

###################################################
#### **** Container package information ****
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${2:-"openkbs/${DOCKER_IMAGE_REPO}"}
imageVersion=${3:-"1.0.0"}

docker ps -a

containerID=`docker ps |grep "${imageTag} "|awk '{print $1}'`
echo "containerID=$containerID"

#docker tag ${imageTag} openkbs/${imageTag}:latest

docker commit -m "$comment" ${containerID} ${imageTag}:latest
docker push ${imageTag}:latest

docker commit -m "$comment" ${containerID} ${imageTag}:${imageVersion}
docker push ${imageTag}:${imageVersion}

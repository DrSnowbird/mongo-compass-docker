#!/bin/bash

# Reference: 
# - https://docs.docker.com/engine/userguide/containers/dockerimages/
# - https://docs.docker.com/engine/reference/commandline/commit/
#     docker push [OPTIONS] NAME[:TAG]
# - https://docs.docker.com/engine/reference/commandline/push/
#     docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

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

ORGANIZATION=${ORGANIZATION:-openkbs}

comment=${1:-Update with the latest changes: `date`}

###################################################
#### **** Container package information ****
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${2:-"${ORGANIZATION}/${DOCKER_IMAGE_REPO}"}
imageVersion=${3:-latest}

docker ps -a

containerID=`docker ps |grep "${imageTag} "|awk '{print $1}'`
echo "containerID=$containerID"

#docker tag ${imageTag} ${imageTag}:latest

#docker commit -m "$comment" ${containerID} ${imageTag}:latest
#docker push ${imageTag}:latest

echo docker commit -m "$comment" ${containerID} ${imageTag}:${imageVersion}
echo docker push ${imageTag}:${imageVersion}

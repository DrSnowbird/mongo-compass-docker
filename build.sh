#!/bin/bash -x

# Reference: 
# - https://docs.docker.com/engine/userguide/containers/dockerimages/
# - https://github.com/dockerfile/java/blob/master/oracle-java8/Dockerfile

if [ $# -lt 1 ]; then
    echo "Usage: "
    echo "  ${0} [<Dockerfile> <imageTag>]"
fi
MY_DIR=$(dirname "$(readlink -f "$0")")

DOCKERFILE=${1:-Dockerfile}

###################################################
#### ---- Change this only if want to use your own
###################################################
ORGANIZATION=openkbs

###################################################
#### ---- Detect docker ----
###################################################
DOCKER_ENV_FILE="./.env"
function detectDockerEnvFile() {
    curr_dir=`pwd`
    if [ -s "./.env" ]; then
        echo "--- INFO: ./.env Docker Environment file (.env) FOUND!"
        DOCKER_ENV_FILE="./.env"
    else
        echo "--- INFO: ./.env Docker Environment file (.env) NOT found!"
        if [ -s "./docker.env" ]; then
            DOCKER_ENV_FILE="./docker.env"
        else
            echo "*** WARNING: Docker Environment file (.env) or (docker.env) NOT found!"
        fi
    fi
}
detectDockerEnvFile

###################################################
#### ---- Container package information ----
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${2:-"${ORGANIZATION}/${DOCKER_IMAGE_REPO}"}

###################################################
#### ---- Generate build-arg arguments ----
###################################################
BUILD_ARGS=""
BUILD_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`"
VCS_REF="`git rev-parse --short HEAD`"
VCS_URL="https://github.com/`echo $(basename $PWD)`"
BUILD_ARGS="--build-arg BUILD_DATE=${BUILD_DATE} --build-arg VCS_REF=${VCS_REF}"

## -- ignore entries start with "#" symbol --
function generateBuildArgs() {
    for r in `cat ${DOCKER_ENV_FILE} | grep -v '^#'`; do
        echo "entry=$r"
        key=`echo $r | tr -d ' ' | cut -d'=' -f1`
        value=`echo $r | tr -d ' ' | cut -d'=' -f2`
        BUILD_ARGS="${BUILD_ARGS} --build-arg $key=$value"
    done
}
generateBuildArgs
echo "BUILD_ARGS=${BUILD_ARGS}"

###################################################
#### ---- Setup Docker Build Proxy ----
###################################################
# export NO_PROXY="localhost,127.0.0.1,.openkbs.org"
# export HTTP_PROXY="http://gatekeeper-w.openkbs.org:80"
# when using "wget", add "--no-check-certificate" to avoid https certificate checking failures
#
HTTP_PROXY_PARAM=
function generateProxyArgs() {
    if [ "${HTTP_PROXY}" != "" ]; then
        HTTP_PROXY_PARAM="--build-arg http_proxy=${HTTP_PROXY} --build-arg https_proxy=${HTTP_PROXY}"
    else
        HTTP_PROXY_PARAM=
    fi
    if [ "${NO_PROXY}" != "" ]; then
        HTTP_PROXY_PARAM="${HTTP_PROXY_PARAM} --build-arg no_proxy=${NO_PROXY}"
    else
        HTTP_PROXY_PARAM=${HTTP_PROXY_PARAM}
    fi
    BUILD_ARGS="${BUILD_ARGS} ${HTTP_PROXY_PARAM}"
}
generateProxyArgs
echo "BUILD_ARGS=${BUILD_ARGS}"

###################################################
#### ---- Buidl Container ----
###################################################

echo "========> imageTag: ${imageTag}"
docker build --rm -t ${imageTag} \
    ${BUILD_ARGS} \
	-f `pwd`/${DOCKERFILE} .

echo "----> Shell into the Container in interactive mode: "
echo "  docker exec -it --name <some-name> /bin/bash"
echo "e.g."
echo "  docker run --name "my-$(basename $imageTag)" /bin/bash "

echo "----> Run: "
echo "  docker run --name <some-name> -it ${imageTag} /bin/bash"
echo "e.g."
echo "  docker run --name "my-$(basename $imageTag)" ${imageTag} "

echo "----> Run in interactive mode: "
echo "  docker run -it --name <some-name> ${imageTag} /bin/bash"
echo "e.g."
echo "  docker run -it --name "my-$(basename $imageTag)" -it ${imageTag} "

echo "----> Build Docker Images again: "
echo "To build again: (there is a dot at the end of the command!)"
echo "  docker build -t ${imageTag} . "
echo
docker images |grep "$imageTag"


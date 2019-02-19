#!/bin/bash

set -e

# Reference: 
# - https://docs.docker.com/engine/userguide/containers/dockerimages/
# - https://github.com/dockerfile/java/blob/master/oracle-java8/Dockerfile

if [ $# -lt 1 ]; then
    echo "-------------------------------------------------------------------------------------------"
    echo "Usage: "
    echo "  ${0} [<Dockerfile> <imageTag> [<some more optional arguments...>] ] "
    echo "e.g."
    echo "  ./build.sh ./centos/Dockerfile.centos.xfce.vnc openkbs/centos-xfce-vnc --no-cache  --build-arg OS_TYPE=centos'"
    echo "  ./build.sh ./Dockerfile.ubuntu.xfce.vnc openkbs/ubuntu-xfce-vnc --no-cache  --build-arg OS_TYPE=centos'"
    echo "-------------------------------------------------------------------------------------------"
fi

MY_DIR=$(dirname "$(readlink -f "$0")")

DOCKERFILE=${1:-./Dockerfile}
DOCKERFILE=$(realpath $DOCKERFILE)
BUILD_CONTEXT=$(dirname ${DOCKERFILE})

imageTag=${2}

if [ $# -gt 2 ]; then
    shift 2
    options="$*"
else 
    options=""
fi

##########################################################
#### ---- Whether to remove previous build cache ---- ####
#### ---- Valid value: 0 (No remove); 1 (yes, remove)
##########################################################
REMOVE_CACHE=0

###############################################################################
###############################################################################
###############################################################################
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
###############################################################################
###############################################################################
###############################################################################

##########################################################
#### ---- Generate remove cache option if needed ---- ####
##########################################################
REMOVE_CACHE_OPTION=""
if [ ${REMOVE_CACHE} -gt 0 ]; then
    REMOVE_CACHE_OPTION="--no-cache --rm"
fi

###################################################
#### ---- Change this only if want to use your own
###################################################
ORGANIZATION=openkbs

###################################################
#### ---- Detect Docker Run Env files ----
###################################################

function detectDockerBuildEnvFile() {
    curr_dir=`pwd`
    if [ -s "${DOCKER_ENV_FILE}" ]; then
        echo "--- INFO: Docker Build Environment file '${DOCKER_ENV_FILE}' FOUND!"
    else
        echo "*** WARNING: Docker Build Environment file '${DOCKER_ENV_FILE}' NOT found!"
        echo "*** WARNING: Searching for .env or docker.env as alternative!"
        echo "*** --->"
        if [ -s "./docker-build.env" ]; then
            echo "--- INFO: ./docker-build.env FOUND to use as Docker Run Environment file!"
            DOCKER_ENV_FILE="./docker-build.env"
        else
            if [ -s "./.env" ]; then
                echo "--- INFO: ./.env FOUND to use as Docker Run Environment file!"
                DOCKER_ENV_FILE="./.env"
            else
                echo "--- INFO: ./.env Docker Environment file (.env) NOT found!"
                if [ -s "./docker.env" ]; then
                    echo "--- INFO: ./docker.env FOUND to use as Docker Run Environment file!"
                    DOCKER_ENV_FILE="./docker.env"
                else
                    echo "*** WARNING: Docker Environment file (.env) or (docker.env) NOT found!"
                fi
            fi
        fi
    fi
}
detectDockerBuildEnvFile

###################################################
#### ---- Container package information ----
###################################################
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag=${imageTag:-"${ORGANIZATION}/${DOCKER_IMAGE_REPO}"}

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
        echo "entry=> $r"
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
echo "... Setup Docker Build Proxy: ..."
PROXY_PARAM=
function generateProxyArgs() {
    if [ "${HTTP_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg HTTP_PROXY=${HTTP_PROXY}"
    fi
    if [ "${HTTPS_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg HTTPS_PROXY=${HTTPS_PROXY}"
    fi
    if [ "${NO_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg NO_PROXY=\"${NO_PROXY}\""
    fi
    if [ "${http_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg http_proxy=${http_proxy}"
    fi
    if [ "${https_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg https_proxy=${https_proxy}"
    fi
    if [ "${no_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} --build-arg no_proxy=\"${no_proxy}\""
    fi
    BUILD_ARGS="${BUILD_ARGS} ${PROXY_PARAM}"
}
generateProxyArgs
echo -e "BUILD_ARGS=> \n ${BUILD_ARGS}"
echo

###################################################
#### ---- Build Container ----
###################################################

cd ${BUILD_CONTEXT}
set -x
docker build ${REMOVE_CACHE_OPTION} -t ${imageTag} \
    ${BUILD_ARGS} \
    ${options} \
    -f $(basename ${DOCKERFILE}) .
set +x
cd -

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


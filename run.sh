#!/bin/bash

set +x

MY_DIR=$(dirname "$(readlink -f "$0")")

if [ $# -lt 1 ]; then
    echo "--------------------------------------------------------"
    echo "Usage: "
    echo "  ${0} <container_shell_command>"
    echo "e.g.: "
    echo "  ${0} ls -al "
    echo "  ${0} /bin/bash "
    echo "--------------------------------------------------------"
fi

###########################################################################
#### ---- RUN Configuration (CHANGE THESE if needed!!!!)           --- ####
###########################################################################
## ------------------------------------------------------------------------
## Valid "BUILD_TYPE" values: 
##    0: (default) has neither X11 nor VNC/noVNC container build image type
##    1: X11/Desktip container build image type
##    2: VNC/noVNC container build image type
## ------------------------------------------------------------------------
BUILD_TYPE=1

## ------------------------------------------------------------------------
## Valid "RUN_TYPE" values: 
##    0: (default) Interactive Container -
##       ==> Best for Debugging Use
##    1: Detach Container / Non-Interactive 
##       ==> Usually, when not in debugging mode anymore, then use 1 as choice.
##       ==> Or, your frequent needs of the container for DEV environment Use.
## ------------------------------------------------------------------------
RUN_TYPE=0

## ------------------------------------------------------------------------
## Change to one (1) if run.sh needs to use host's user/group to run the Container
## Valid "USER_VARS_NEEDED" values: 
##    0: (default) Not using host's USER / GROUP ID
##    1: Yes, using host's USER / GROUP ID for Container running.
## ------------------------------------------------------------------------
USER_VARS_NEEDED=0

## ------------------------------------------------------------------------
## Valid "RESTART_OPTION" values:
##  { no, on-failure, unless-stopped, always }
## ------------------------------------------------------------------------
#ESTART_OPTION=no
RESTART_OPTION=unless-stopped

## ------------------------------------------------------------------------
## More optional values:
##   Add any additional options here
## ------------------------------------------------------------------------
#MORE_OPTIONS="--privileged=true"
MORE_OPTIONS=""

###############################################################################
###############################################################################
###############################################################################
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
#### ---- DO NOT Change the code below UNLESS you really want to !!!!) --- ####
###############################################################################
###############################################################################
###############################################################################

########################################
#### ---- Correctness Checking ---- ####
########################################
RESTART_OPTION=`echo ${RESTART_OPTION} | sed 's/ //g' | tr '[:upper:]' '[:lower:]' `
REMOVE_OPTION=" --rm "
if [ "${RESTART_OPTION}" != "no" ]; then
    REMOVE_OPTION=""
fi

########################################
#### ---- Usage for BUILD_TYPE ---- ####
########################################
function buildTypeUsage() {
    echo "## ------------------------------------------------------------------------"
    echo "## Valid BUILD_TYPE values: "
    echo "##    0: (default) has neither X11 nor VNC/noVNC container build image type"
    echo "##    1: X11/Desktip container build image type"
    echo "##    2: VNC/noVNC container build image type"
    echo "## ------------------------------------------------------------------------"
}

if [ "${BUILD_TYPE}" -lt 0 ] || [ "${BUILD_TYPE}" -gt 2 ]; then
    buildTypeUsage
    exit 1
fi

########################################
#### ---- Validate RUN_TYPE    ---- ####
########################################
 
RUN_OPTION=${RUN_OPTION:-" -it "}
function validateRunType() {
    case "${RUN_TYPE}" in
        0 )
            RUN_OPTION=" -it "
            ;;
        1 )
            RUN_OPTION=" -d "
            ;;
        * )
            echo "**** ERROR: Incorrect RUN_TYPE: ${RUN_TYPE} is used! Abort ****"
            exit 1
            ;;
    esac
}
validateRunType
echo "RUN_TYPE=${RUN_TYPE}"
echo "RUN_OPTION=${RUN_OPTION}"
echo "RESTART_OPTION=${RESTART_OPTION}"
echo "REMOVE_OPTION=${REMOVE_OPTION}"

###########################################################################
## -- docker-compose or docker-stack use only --
###########################################################################

## -- (this script will include ./.env only if "./docker-run.env" not found
DOCKER_ENV_FILE="./docker-run.env"

###########################################################################
#### (Optional - to filter Environmental Variables for Running Docker)
###########################################################################
ENV_VARIABLE_PATTERN=""

###################################################
#### ---- Change this only to use your own ----
###################################################
ORGANIZATION=openkbs
baseDataFolder="$HOME/data-docker"

###################################################
#### **** Container package information ****
###################################################
MY_IP=`ip route get 1|awk '{print$NF;exit;}'`
DOCKER_IMAGE_REPO=`echo $(basename $PWD)|tr '[:upper:]' '[:lower:]'|tr "/: " "_" `
imageTag="${ORGANIZATION}/${DOCKER_IMAGE_REPO}"
#PACKAGE=`echo ${imageTag##*/}|tr "/\-: " "_"`
PACKAGE="${imageTag##*/}"

###################################################
#### ---- (DEPRECATED but still supported)    -----
#### ---- Volumes to be mapped (change this!) -----
###################################################
# (examples)
# IDEA_PRODUCT_NAME="IdeaIC2017"
# IDEA_PRODUCT_VERSION="3"
# IDEA_INSTALL_DIR="${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
# IDEA_CONFIG_DIR=".${IDEA_PRODUCT_NAME}.${IDEA_PRODUCT_VERSION}"
# IDEA_PROJECT_DIR="IdeaProjects"
# VOLUMES_LIST="${IDEA_CONFIG_DIR} ${IDEA_PROJECT_DIR}"

# ---------------------------
# Variable: VOLUMES_LIST
# (NEW: use docker.env with "#VOLUMES_LIST=data workspace" to define entries)
# ---------------------------
## -- If you defined locally here, 
##    then the definitions of volumes map in "docker.env" will be ignored.
# VOLUMES_LIST="data workspace"

# ---------------------------
# OPTIONAL Variable: PORT PAIR
# (NEW: use docker.env with "#PORTS=18000:8000 17200:7200" to define entries)
# ---------------------------
## -- If you defined locally here, 
##    then the definitions of ports map in "docker.env" will be ignored.
#### Input: PORT - list of PORT to be mapped
# (examples)
#PORTS_LIST="18000:8000"
#PORTS_LIST=

#########################################################################################################
######################## DON'T CHANGE LINES STARTING BELOW (unless you need to) #########################
#########################################################################################################
LOCAL_VOLUME_DIR="${baseDataFolder}/${PACKAGE}"
## -- Container's internal Volume base DIR
DOCKER_VOLUME_DIR="/home/developer"

###################################################
#### ---- Detect Docker Run Env files ----
###################################################

function detectDockerRunEnvFile() {
    curr_dir=`pwd`
    if [ -s "${DOCKER_ENV_FILE}" ]; then
        echo "--- INFO: Docker Run Environment file '${DOCKER_ENV_FILE}' FOUND!"
    else
        echo "*** WARNING: Docker Run Environment file '${DOCKER_ENV_FILE}' NOT found!"
        echo "*** WARNING: Searching for .env or docker.env as alternative!"
        echo "*** --->"
        if [ -s "./docker-run.env" ]; then
            echo "--- INFO: ./docker-run.env FOUND to use as Docker Run Environment file!"
            DOCKER_ENV_FILE="./docker-run.env"
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
detectDockerRunEnvFile

###################################################
#### ---- Function: Generate volume mappings  ----
####      (Don't change!)
###################################################
VOLUME_MAP=""
#### Input: VOLUMES - list of volumes to be mapped
hasPattern=0
function hasPattern() {
    detect=`echo $1|grep "$2"`
    if [ "${detect}" != "" ]; then
        hasPattern=1
    else
        hasPattern=0
    fi
}

DEBUG=0
function debug() {
    if [ $DEBUG -gt 0 ]; then
        echo $*
    fi
}

function generateVolumeMapping() {
    if [ "$VOLUMES_LIST" == "" ]; then
        ## -- If locally defined in this file, then respect that first.
        ## -- Otherwise, go lookup the docker.env as ride-along source for volume definitions
        VOLUMES_LIST=`cat ${DOCKER_ENV_FILE}|grep "^#VOLUMES_LIST= *"|sed "s/[#\"]//g"|cut -d'=' -f2-`
    fi
    for vol in $VOLUMES_LIST; do
        debug "$vol"
        hasColon=`echo $vol|grep ":"`
        ## -- allowing change local volume directories --
        if [ "$hasColon" != "" ]; then
            left=`echo $vol|cut -d':' -f1`
            right=`echo $vol|cut -d':' -f2`
            leftHasDot=`echo $left|grep "\./"`
            if [ "$leftHasDot" != "" ]; then
                ## has "./data" on the left
                if [[ ${right} == "/"* ]]; then
                    ## -- pattern like: "./data:/containerPath/data"
                    debug "-- pattern like ./data:/data --"
                    VOLUME_MAP="${VOLUME_MAP} -v `pwd`/${left}:${right}"
                else
                    ## -- pattern like: "./data:data"
                    debug "-- pattern like ./data:data --"
                    VOLUME_MAP="${VOLUME_MAP} -v `pwd`/${left}:${DOCKER_VOLUME_DIR}/${right}"
                fi
                mkdir -p `pwd`/${left}
                if [ $DEBUG -gt 0 ]; then ls -al `pwd`/${left}; fi
            else
                ## No "./data" on the left
                if [[ ${right} == "/"* ]]; then
                    ## -- pattern like: "data:/containerPath/data"
                    debug "-- pattern like ./data:/data --"
                    VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/${left}:${right}"
                else
                    ## -- pattern like: "data:data"
                    debug "-- pattern like data:data --"
                    VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/${left}:${DOCKER_VOLUME_DIR}/${right}"
                fi
                mkdir -p ${LOCAL_VOLUME_DIR}/${left}
                if [ $DEBUG -gt 0 ]; then ls -al ${LOCAL_VOLUME_DIR}/${left}; fi
            fi
        else
            ## -- pattern like: "data"
            debug "-- default sub-directory (without prefix absolute path) --"
            VOLUME_MAP="${VOLUME_MAP} -v ${LOCAL_VOLUME_DIR}/$vol:${DOCKER_VOLUME_DIR}/$vol"
            mkdir -p ${LOCAL_VOLUME_DIR}/$vol
            if [ $DEBUG -gt 0 ]; then ls -al ${LOCAL_VOLUME_DIR}/$vol; fi
        fi
    done
}
#### ---- Generate Volumes Mapping ----
generateVolumeMapping
echo ${VOLUME_MAP}

###################################################
#### ---- Function: Generate port mappings  ----
####      (Don't change!)
###################################################
PORT_MAP=""
function generatePortMapping() {
    if [ "$PORTS" == "" ]; then
        ## -- If locally defined in this file, then respect that first.
        ## -- Otherwise, go lookup the ${DOCKER_ENV_FILE} as ride-along source for volume definitions
        PORTS_LIST=`cat ${DOCKER_ENV_FILE}|grep "^#PORTS_LIST= *"|sed "s/[#\"]//g"|cut -d'=' -f2-`
    fi
    for pp in ${PORTS_LIST}; do
        #echo "$pp"
        port_pair=`echo $pp |  tr -d ' ' `
        if [ ! "$port_pair" == "" ]; then
            # -p ${local_dockerPort1}:${dockerPort1} 
            host_port=`echo $port_pair | tr -d ' ' | cut -d':' -f1`
            docker_port=`echo $port_pair | tr -d ' ' | cut -d':' -f2`
            PORT_MAP="${PORT_MAP} -p ${host_port}:${docker_port}"
        fi
    done
}
#### ---- Generate Port Mapping ----
generatePortMapping
echo "PORT_MAP=${PORT_MAP}"

###################################################
#### ---- Generate Environment Variables       ----
###################################################
ENV_VARS=""
function generateEnvVars() {
    if [ "${1}" != "" ]; then
        ## -- product key patterns, e.g., "^MYSQL_*"
        #productEnvVars=`grep -E "^[[:blank:]]*$1[a-zA-Z0-9_]+[[:blank:]]*=[[:blank:]]*[a-zA-Z0-9_]+[[:blank:]]*" ${DOCKER_ENV_FILE}`
        productEnvVars=`grep -E "^[[:blank:]]*$1.+[[:blank:]]*=[[:blank:]]*.+[[:blank:]]*" ${DOCKER_ENV_FILE} | grep -v "^#" | grep "${1}"`
    else
        ## -- product key patterns, e.g., "^MYSQL_*"
        #productEnvVars=`grep -E "^[[:blank:]]*$1[a-zA-Z0-9_]+[[:blank:]]*=[[:blank:]]*[a-zA-Z0-9_]+[[:blank:]]*" ${DOCKER_ENV_FILE}`
        productEnvVars=`grep -E "^[[:blank:]]*$1.+[[:blank:]]*=[[:blank:]]*.+[[:blank:]]*" ${DOCKER_ENV_FILE} | grep -v "^#"`
    fi
    ENV_VARS_STRING=""
    for vars in ${productEnvVars// /}; do
        debug "Entry => $vars"
        if [ "$1" != "" ]; then
            matched=`echo $vars|grep -E "${1}"`
            if [ ! "$matched" == "" ]; then
                ENV_VARS_STRING="${ENV_VARS_STRING} ${vars}"
            fi
        else
            ENV_VARS_STRING="${ENV_VARS_STRING} ${vars}"
        fi
    done
    ## IFS default is "space tab newline" already
    #IFS=',; ' read -r -a ENV_VARS_ARRAY <<< "${ENV_VARS_STRING}"
    read -r -a ENV_VARS_ARRAY <<< "${ENV_VARS_STRING}"
    # To iterate over the elements:
    for element in "${ENV_VARS_ARRAY[@]}"
    do
        ENV_VARS="${ENV_VARS} -e ${element}"
    done
    if [ $DEBUG -gt 0 ]; then echo "ENV_VARS_ARRAY=${ENV_VARS_ARRAY[@]}"; fi
}
generateEnvVars
echo "ENV_VARS=${ENV_VARS}"

###################################################
#### ---- Setup Docker Build Proxy ----
###################################################
# export NO_PROXY="localhost,127.0.0.1,.openkbs.org"
# export HTTP_PROXY="http://gatekeeper-w.openkbs.org:80"
# when using "wget", add "--no-check-certificate" to avoid https certificate checking failures
# Note: You can also setup Docker CLI configuration file (~/.docker/config.json), e.g.
# {
#   "proxies": {
#     "default": {
#       "httpProxy": "http://gatekeeper-w.openkbs.org:80"
#       "httpsProxy": "http://gatekeeper-w.openkbs.org:80"
#      }
#    }
#  }
#
echo "... Setup Docker Run Proxy: ..."

PROXY_PARAM=
function generateProxyEnv() {
    if [ "${HTTP_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e HTTP_PROXY=${HTTP_PROXY}"
    fi
    if [ "${HTTPS_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e HTTPS_PROXY=${HTTPS_PROXY}"
    fi
    if [ "${NO_PROXY}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e NO_PROXY=\"${NO_PROXY}\""
    fi
    if [ "${http_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e HTTP_PROXY=${http_proxy}"
    fi
    if [ "${https_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e HTTPS_PROXY=${https_proxy}"
    fi
    if [ "${no_proxy}" != "" ]; then
        PROXY_PARAM="${PROXY_PARAM} -e NO_PROXY=\"${no_proxy}\""
    fi
    ENV_VARS="${ENV_VARS} ${PROXY_PARAM}"
}
generateProxyEnv
echo "ENV_VARS=${ENV_VARS}"

###################################################
#### ---- Function: Generate privilege String  ----
####      (Don't change!)
###################################################
privilegedString=""
function generatePrivilegedString() {
    OS_VER=`which yum`
    if [ "$OS_VER" == "" ]; then
        # Ubuntu
        echo "Ubuntu ... not SE-Lunix ... no privileged needed"
    else
        # CentOS/RHEL
        privilegedString="--privileged"
    fi
}
generatePrivilegedString
echo ${privilegedString}

###################################################
#### ---- Mostly, you don't need change below ----
###################################################
function cleanup() {
    if [ ! "`docker ps -a|grep ${instanceName}`" == "" ]; then
         docker rm -f ${instanceName}
    fi
}

function displayURL() {
    port=${1}
    echo "... Go to: http://${MY_IP}:${port}"
    #firefox http://${MY_IP}:${port} &
    if [ "`which google-chrome`" != "" ]; then
        /usr/bin/google-chrome http://${MY_IP}:${port} &
    else
        firefox http://${MY_IP}:${port} &
    fi
}

###################################################
#### ---- Replace "Key=Value" with new value   ----
###################################################
function replaceKeyValue() {
    inFile=${1:-${DOCKER_ENV_FILE}}
    keyLike=$2
    newValue=$3
    if [ "$2" == "" ]; then
        echo "**** ERROR: Empty Key value! Abort!"
        exit 1
    fi
    sed -i -E 's/^('$keyLike'[[:blank:]]*=[[:blank:]]*).*/\1'$newValue'/' $inFile
}
#### ---- Replace docker.env with local user's UID and GID ----
#replaceKeyValue ${DOCKER_ENV_FILE} "USER_ID" "$(id -u $USER)"
#replaceKeyValue ${DOCKER_ENV_FILE} "GROUP_ID" "$(id -g $USER)"

###################################################
#### ---- Get "Key=Value" withe new value ----
#### Usage: getKeyValuePair <inFile> <key>
#### Output: Key=Value
###################################################
KeyValuePair=""
function getKeyValuePair() {
    KeyValuePair=""
    inFile=${1:-${DOCKER_ENV_FILE}}
    keyLike=$2
    if [ "$2" == "" ]; then
        echo "**** ERROR: Empty Key value! Abort!"
        exit 1
    fi
    matchedKV=`grep -E "^[[:blank:]]*${keyLike}.+[[:blank:]]*=[[:blank:]]*.+[[:blank:]]*" ${DOCKER_ENV_FILE}`
    for kv in $matchedKV; do
        echo "KeyValuePair=${matchedKV// /}"
    done
}
#getKeyValuePair "${DOCKER_ENV_FILE}" "MYSQL_DATABASE"

## -- transform '-' and space to '_' 
#instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/\-: " "_"`
instanceName=`echo $(basename ${imageTag})|tr '[:upper:]' '[:lower:]'|tr "/: " "_"`

################################################
##### ---- Product Specific Parameters ---- ####
################################################
#MYSQL_DATABASE=${MYSQL_DATABASE:-myDB}
#MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-password}
#MYSQL_USER=${MYSQL_USER:-user1}
#MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}
#### ---- Generate Env. Variables ----
echo ${ENV_VARS}

echo "---------------------------------------------"
echo "---- Starting a Container for ${imageTag}"
echo "---------------------------------------------"

cleanup

#################################
## -- USER_VARS into Docker -- ##
#################################
if [ ${USER_VARS_NEEDED} -gt 0 ]; then
    USER_VARS="--user $(id -u $USER)"
fi

echo "--------------------------------------------------------"
echo "==> Commands to manage Container:"
echo "--------------------------------------------------------"
echo "  ./shell.sh : to shell into the container"
echo "  ./stop.sh  : to stop the container"
echo "  ./log.sh   : to show the docker run log"
echo "  ./build.sh : to build the container"
echo "  ./commit.sh: to push the container image to docker hub"
echo "--------------------------------------------------------"

case "${BUILD_TYPE}" in
    0)
        ## 0: (default) has neither X11 nor VNC/noVNC container build image type 
        set -x 
        docker run ${REMOVE_OPTION} ${MORE_OPTIONS} ${RUN_OPTION} \
            --name=${instanceName} \
            --restart=${RESTART_OPTION} \
            ${privilegedString} \
            ${USER_VARS} \
            ${ENV_VARS} \
            ${VOLUME_MAP} \
            ${PORT_MAP} \
            ${imageTag} $*
        ;;
    1)
        ## 1: X11/Desktip container build image type
        #### ---- for X11-based ---- ####
        echo ${DISPLAY}
        xhost +SI:localuser:$(id -un) 
        set -x 
        DISPLAY=${MY_IP}:0 \
        docker run ${REMOVE_OPTION} ${MORE_OPTIONS} ${RUN_OPTION} \
            --name=${instanceName} \
            --restart=${RESTART_OPTION} \
            -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            ${privilegedString} \
            ${USER_VARS} \
            ${ENV_VARS} \
            ${VOLUME_MAP} \
            ${PORT_MAP} \
            ${imageTag} $*
        ;;
    2)
        ## 2: VNC/noVNC container build image type
        #### ----------------------------------- ####
        #### -- VNC_RESOLUTION setup default --- ####
        #### ----------------------------------- ####
        if [ "`echo $ENV_VARS|grep VNC_RESOLUTION`" = "" ]; then
            #VNC_RESOLUTION=1280x1024
            VNC_RESOLUTION=1920x1080
            ENV_VARS="${ENV_VARS} -e VNC_RESOLUTION=${VNC_RESOLUTION}" 
        fi
        set -x 
        docker run ${REMOVE_OPTION} ${MORE_OPTIONS} ${RUN_OPTION} \
            --name=${instanceName} \
            --restart=${RESTART_OPTION} \
            ${privilegedString} \
            ${USER_VARS} \
            ${ENV_VARS} \
            ${VOLUME_MAP} \
            ${PORT_MAP} \
            ${imageTag} $*
        ;;
     *)
        buildTypeUsage
        exit 1
esac

set +x


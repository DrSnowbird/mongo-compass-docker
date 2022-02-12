#!/bin/bash

set -e

printenv

WAIT_SEC=60

#e.g. /home/developer/denodo-platform-7.0/bin/denodo_platform.sh
 
if [ "${PRODUCT_EXE}" == "" ]; then
    echo "*** ERROR ****: PRODUCT_EXE variable is not defined in Dockerfile or not exported!"
    exit 1
fi

if [ $# -gt 0 ]; then

PROC_PATTERN="$(basename {PRODUCT_EXE})"

/bin/bash -c ${PRODUCT_EXE}

sleep ${WAIT_SEC}

PID=`ps -elf|grep "${PROC_PATTERN}" | grep -v grep | awk '{print $4}' | head -1`

#### Serveral options to make
while [ "${PID}" != "" ]
do
    echo "Process: $PID is still running"
    sleep ${WAIT_SEC}
    PID=`ps -elf|grep "${PROC_PATTERN}" | grep -v grep | awk '{print $4}' | head -1`
done
#wait ${PID}

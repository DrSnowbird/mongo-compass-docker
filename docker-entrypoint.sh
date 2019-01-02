#!/bin/bash -x

set -e
set -i
env

#### ---- Make sure to provide Non-root user for launching Docker ----
#### ---- Default, we use base images's "developer"               ----
NON_ROOT_USER=${NON_ROOT_USER:-"developer"}

#### ------------------------------------------------------------------------
#### ---- You need to set PRODUCT_EXE as the full-path executable binary ----
#### ------------------------------------------------------------------------
echo "Starting docker process daemon ..."
if [ "${PRODUCT_EXE}" == "" ]; then
    PRODUCT_EXE=${PRODUCT_EXE:-echo Hello}
    /bin/bash -c "${PRODUCT_EXE:-echo Hello}"
fi

#### ------------------------------------------------------------------------
#### ---- Extra line added in the script to run all command line arguments
#### ---- To keep the docker process staying alive if needed.
#### ------------------------------------------------------------------------

if [ $# -gt 0 ]; then
    #### **** Allow non-root users to bind to use lower than 1000 ports **** ####
    USE_CAP_NET_BIND=${USE_CAP_NET_BIND:-0}
    if [ ${USE_CAP_NET_BIND} -gt 0 ]; then
        sudo setcap 'cap_net_bind_service=+ep' ${PRODUCT_EXE}
    fi

    #### 1.) Setup needed stuffs, e.g., init db etc. ....
    #### (do something here for preparation)
    
    #### 2.A) As Root User -- Choose this or 2.B --####
    #### ---- Use this when running Root user ---- ####
    exec "$@"
    #/bin/bash -c "$@"
    
    #### 2.B) As Non-Root User -- Choose this or 2.A  ---- #### 
    #### ---- Use this when running Non-Root user ---- ####
    #### ---- Use gosu (or su-exec) to drop to a non-root user
    #exec gosu ${NON_ROOT_USER} ${PRODUCT_EXE} "$@"
else
    exec "${PRODUCT_EXE}";
fi


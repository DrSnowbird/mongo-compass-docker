#!/bin/bash -x

echo "####################### Components: $(basename $0) ###########################"

if [ -s "/usr/bin/sudo" ]; then
    sudo=sudo
else
    sudo=""
fi

cat /etc/*rel*

find . -name "ca-certificates"

if [ "$1" != "" ]; then
    SOURCE_CERTIFICATES_DIR=${SOURCE_CERTIFICATES_DIR:-$1}
else
    SOURCE_CERTIFICATES_DIR=${SOURCE_CERTIFICATES_DIR:-/certificates}
fi

#### ---------------------------------------------------------------------------------------------------------------------------------- ####
#### ---- (ref: https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself)
#### ---------------------------------------------------------------------------------------------------------------------------------- ####
function findMyAbsDir() {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    MY_ABS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
}
# findMyAbsDir
MY_ABS_DIR=$(dirname "$(readlink -f "$0")")

#### ---- Usage ---- ####
function usage() {
    echo "Usage setup_system_certificates -d <certificates_dir> [ -h | --help]"
}

#### ---- Usage ---- ####
ORIG_ARGS="$*"
SHORT="hd:"
LONG="help,certificates_dir:"

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
#OPTIONS=$(getopt --options ${SHORT} --longoptions ${LONG} --name "$0" -a -- "$@")
OPTIONS=$(getopt -o ${SHORT} -l ${LONG} --name "$0" -a -- "$@")

if [[ $? != 0 ]]; then
    echo "Arguments Parsing Error! Abort!"
    exit 1
fi
eval set -- "${OPTIONS}"

while true; do
    case "$1" in
        -h|--help)
            usage "Usage setup_system_certificates -d <certificates_dir> [ -h | --help]"
            ;;
        -d|--certificates_dir)
            shift
            SOURCE_CERTIFICATES_DIR=$1
            echo "SOURCE_CERTIFICATES_DIR=$SOURCE_CERTIFICATES_DIR"
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "*****: input args error"
            echo "$ORIG_ARGS"
            exit 3
            ;;
    esac
    shift
done

echo "ORIGINAL INPUT >>>>>>>>>>:"
echo "${ORIG_ARGS}"
echo "-------------"

#### -------------------------------------------------
#### OS_TYPE=1:Ubuntu, 2:Centos,, 0: OS_TYPE_NOT_FOUND
#### -------------------------------------------------
OS_TYPE=0

REPO_CONF=/etc/apt/apt.conf
ETC_ENV=/etc/environment

function detectOS_alt() {
    os_name="`which yum`"
    if [ "$os_name" = "" ]; then
        os_name="`which apt`"
        if [ "$os_name" = "" ]; then
            OS_TYPE=0
        else
            OS_TYPE=1
        fi
    else
        OS_TYPE=2
    fi
 
}
detectOS_alt

function detectOS() {
    os_name="`cat /etc/os-release | grep -i '^NAME=\"Ubuntu\"' | awk -F= '{print $2}' | tr '[:upper:]' '[:lower:]' |sed 's/"//g' `"
    case ${os_name} in
        ubuntu*)
            OS_TYPE=1
            REPO_CONF=/etc/apt/apt.conf
            ETC_ENV=/etc/environment
            ;;
        centos*)
            OS_TYPE=2
            REPO_CONF=/etc/yum.conf
            ETC_ENV=/etc/environment
            ;;
        *)
            OS_TYPE=0
            REPO_CONF=
            ETC_ENV=
            echo "***** ERROR: Can't detect OS Type (e.g., Ubuntu, Centos)! *****"
            echo "Abort now!"
            exit 9
            ;;
    esac
}

#### --------------------------------------------------------------------------------------------
#### After these steps the new CA is known by system utilities like curl and get. 
#### Unfortunately, this does not affect most web browsers like Mozilla Firefox or Google Chrome.
#### -------------------------------------------------------------------------------------------- 
## -- CentOS
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/pki/ca-trust/source/anchors}
## -- Debian/Ubuntu
# /etc/ca-certificates
# /usr/local/share/ca-certificates
# /usr/sbin/update-ca-certificates
# /usr/share/doc/ca-certificates
# /usr/share/ca-certificates
# /var/lib/dpkg/triggers/update-ca-certificates
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/usr/local/share/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/usr/share/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/ssl/certs}

## -- Converting from PEM to CRT: -- ##
## openssl x509 -ouform der -in Some-Certificate.pem -out Some-Certificate.crt

#    update-ca-certificates # (for Ubuntu OS)
#    # update-ca-trust extract # (for CentOS OS)
#### (Unbunt version)
#TARGET_CERTIFICATES_DIR=/usr/local/share/ca-certificates/extra
if [ $OS_TYPE -eq 1 ]; then
    # Ubuntu
    CERT_COMMAND=`which update-ca-certificates`
    CMD_OPT=
    TARGET_CERTIFICATES_DIR=/usr/local/ca-certificates
    if [ -s /usr/local/share/ca-certificates ]; then
        TARGET_CERTIFICATES_DIR=/usr/local/share/ca-certificates
    fi
else
    if [ $OS_TYPE -eq 2 ]; then
        # CentOS
        CERT_COMMAND=`which update-ca-trust`
        TARGET_CERTIFICATES_DIR=/etc/pki/ca-trust/source/anchors
        CMD_OPT=extract
    else
        echo "OS_TYPE Unknown! Can't do! Abort!"
        exit 1
    fi
fi

function setupSystemCertificates() {
    echo "================= Setup System Certificates ===================="
    if [ ! -s ${TARGET_CERTIFICATES_DIR} ]; then
        echo -e "*** TARGET_CERTIFICATES_DIR: ${TARGET_CERTIFICATES_DIR}: Not Found!"
        $sudo mkdir -p ${TARGET_CERTIFICATES_DIR}
    fi
    if [ -s /etc/ca-certificates/update.d/docker-openjdk ]; then
        cat /etc/ca-certificates/update.d/docker-openjdk
        echo ">> JAVA PATH=`which java`"
        $sudo sed -i "s#\$JAVA_HOME#$JAVA_HOME#g" /etc/ca-certificates/update.d/docker-openjdk
        env | grep -i java
        $sudo cat /etc/ca-certificates/update.d/docker-openjdk
    fi
    for cert in `cd ${SOURCE_CERTIFICATES_DIR} && ls * | grep -v dummy`; do
        ## -- Converting from PEM to CRT: -- ##
        ## openssl x509 -ouform der -in Some-Certificate.pem -out Some-Certificate.crt
        if [[ "${cert}" == *"pem" ]]; then
            openssl x509 -ouform der -in ${SOURCE_CERTIFICATES_DIR}/${cert} -out ${cert//pem/crt}
        fi
        if [[ "${cert}" == *"crt" ]]; then
            #$sudo cp root.cert.pem /usr/local/share/ca-certificates/root.cert.crt
            cert_basename=$(basename $cert)
            $sudo cp ${SOURCE_CERTIFICATES_DIR}/${cert} ${TARGET_CERTIFICATES_DIR}/$(basename ${cert})
        else
            echo "... ignore non-certificate file: $cert"
        fi
    done
    #$sudo update-ca-certificates
    $sudo ${CERT_COMMAND} ${CMD_OPT}
}
setupSystemCertificates 

#### --------------------------------------------------------------------------------------------
#### ---- Browsers (Firefox, Chromium, etc.) Root Certificates Setup
#### ---- (ref: https://thomas-leister.de/en/how-to-import-ca-root-certificate/)
#### --------------------------------------------------------------------------------------------
function setupBrowserRootCertificates() {
    ### Script installs root.cert.pem to certificate trust store of applications using NSS
    ### (e.g. Firefox, Thunderbird, Chromium)
    ### Mozilla uses cert8, Chromium and Chrome use cert9

    ###
    ### Requirement: apt install libnss3-tools
    ###


    ###
    ### CA file to install (CUSTOMIZE!)
    ###

    certfile="root.cert.pem"
    certname="My Root CA"

    ###
    ### For cert8 (legacy - DBM)
    ###

    for certDB in $(find ~/ -name "cert8.db")
    do
        certdir=$(dirname ${certDB});
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
    done

    ###
    ### For cert9 (SQL)
    ###

    for certDB in $(find ~/ -name "cert9.db")
    do
        certdir=$(dirname ${certDB});
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
    done
}


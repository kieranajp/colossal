#!/bin/sh
# Helper functions

#Set Helper imported to 1
export HELPER_IMPORTED=1
# Set debbuging if needed
[ "${LOG_LEVEL}" = "debug" ] && set -x

# Check if we need to be me more verbose
checkDebug(){
    [ "${LOG_LEVEL}" = "debug" ] && set -x
}

# Set consul adder
export CONSUL_ADDR="${CONSUL-localhost}"

# Run a script if the file exists
# $1 path to file
# $2 Message to print before exection (optional)
execIfExists(){
    CUSTOM_SCRIPT="${1}"

    if [ -f "${CUSTOM_SCRIPT}" ]; then
        MSG="${2-* Executing custom ${1} script}"
        chmod +x "${CUSTOM_SCRIPT}"
        echo "${MSG}"
        ${CUSTOM_SCRIPT}
    fi
}

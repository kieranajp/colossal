#!/bin/sh
## This script is called after app stop
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CUSTOM_SCRIPT="/hooks/postStop"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom postStop script"
    ${CUSTOM_SCRIPT}
fi

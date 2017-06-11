#!/bin/sh
## This script is called to stop the app
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CUSTOM_SCRIPT="/hooks/stop"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom prestart stop"
    ${CUSTOM_SCRIPT}
fi

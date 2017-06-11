#!/bin/sh
## This script is called before app starts
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CUSTOM_SCRIPT="/hooks/preStart"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom preStart script"
    ${CUSTOM_SCRIPT}
fi

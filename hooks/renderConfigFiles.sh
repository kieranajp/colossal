#!/bin/sh
## This script is called to run config render
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CUSTOM_SCRIPT="/hooks/renderConfigFiles"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom configuration files script run"
    ${CUSTOM_SCRIPT}
fi

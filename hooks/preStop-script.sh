#!/bin/sh
## This script is called before app stops
set -e

[ "${LOG_LEVEL}" = "debug" ] && set -x

CUSTOM_SCRIPT="/hooks/prestop"
if [ -x "${CUSTOM_SCRIPT}" ]; then
    echo "* Custom prestop script"
    ${CUSTOM_SCRIPT}
fi

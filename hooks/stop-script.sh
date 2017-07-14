#!/bin/sh
## This script is called to stop the app
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# Execute Hook stop if exists
execIfExists "/hooks/stop" "* Custom stop script"

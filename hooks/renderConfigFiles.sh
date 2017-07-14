#!/bin/sh
## This script is called to run config render
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# Execute Hook preStop if exists
execIfExists "/hooks/renderConfigFiles" "* renderConfigFiles script"

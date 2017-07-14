#!/bin/sh
## This script is called before app stops
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# Execute Hook preStop if exists
execIfExists "/hooks/preStop" "* Custom preStop script"

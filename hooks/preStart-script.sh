#!/bin/sh
## This script is called before app starts
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# Execute Hook preStart if exists
execIfExists "/hooks/preStart" "* Custom preStart script"

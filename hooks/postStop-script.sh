#!/bin/sh
## This script is called after app stop
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# Execute Hook postStop if exists
execIfExists "/hooks/postStop" "* Custom postStop script"


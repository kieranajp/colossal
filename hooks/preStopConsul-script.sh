#!/bin/sh
## This script is called before consul-agent stops
set -e

# shellcheck disable=SC1091
[ -z "${HELPER_IMPORTED+x}" ] && . /usr/local/bin/helper.sh

# shellcheck disable=SC1091
if ! [ -z "${HAPROXY_MANAGE_BACKENDS+x}" ]; then
    echo "* Going to maintaince mode for service ${HOSTNAME}-${APP_NAME}"
    consul maint -enable -service="${HOSTNAME}-${APP_NAME}" -reason="Being shutdown..."
    sleep 4
    echo ""
fi

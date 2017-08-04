#!/bin/sh

echo "_____ init ______"
if [ -f /etc/reloaded ]; then
    echo "* Skiping reload since variables are defined = ${APP_INTERFACES_STATIC}"
else
    echo ""
    APP_INTERFACES_STATIC='192.168.110.11'
    echo "* Using static IP : ${APP_INTERFACES_STATIC}"

    # Set env
    containerpilot -config /etc/containerpilot.json5 -putenv APP_INTERFACES_STATIC="${APP_INTERFACES_STATIC}"
    containerpilot -config /etc/containerpilot.json5 -putenv CONTAINER_PILOT_RELOADED="1"

    # Guard file don't issue term
    touch /tmp/dont_term
    # Guard file don't reload container again
    touch /etc/reloaded

    echo "* Reloading container pilot"
    containerpilot -config /etc/containerpilot.json5 -reload
fi
echo ""
sleep 1

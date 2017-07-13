#!/bin/sh

if [ -x "/hooks/preContainerPilot" ]; then
    echo "* Sourcing custom /hooks/preContainerPilot"
    . /hooks/preContainerPilot
    echo "* ENV"
    env
fi

exec env /bin/containerpilot -config /etc/containerpilot.json5

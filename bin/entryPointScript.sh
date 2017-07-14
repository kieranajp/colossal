#!/bin/sh

if [ -f "/hooks/preContainerPilot" ]; then
    echo "* Sourcing custom /hooks/preContainerPilot"
    chmod +x /hooks/preContainerPilot
    # shellcheck disable=SC1091
    . /hooks/preContainerPilot
fi

exec env /bin/containerpilot -config /etc/containerpilot.json5

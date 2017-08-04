#!/bin/sh
set -e

# In some condition i.e. reloading config we want to skip doing any killing
# So we can use a guard file /tmp/dont_term

if [ -f /tmp/dont_term ]; then
    # Remove guard file so we only skip once
    rm /tmp/dont_term
    echo "* Ignoreing term due to gaurd file"
else
    echo "****** term job initiated *****"
    echo "* "${1}" JOB ${2} "
    echo "* Sending TERM signal to ContainerPilot"
    echo ""
    kill -s TERM 1
fi

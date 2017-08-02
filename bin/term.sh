#!/bin/sh
set -e

echo "****** term job initiated *****"
echo "* ${1} JOB failed or stopped"
echo "* Sending TERM signal to ContainerPilot"
echo ""
kill -TERM 1

#!/bin/sh

echo COLOSSAL="${COLOSSAL}" >> /var/log/hooks.log

# Start application
/usr/bin/nc -l 3030

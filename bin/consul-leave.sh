#!/bin/sh

if pgrep cosnul > /dev/null; then
    echo "* Issuing Consul leave command"
    consul leave
else
       echo "* [warning] Consul is not running can't issue a leave command"
fi

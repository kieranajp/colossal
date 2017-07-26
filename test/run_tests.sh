#!/bin/sh
## This script orchestrates the test-kitchen
set -ex

DIR="$(cd "$(dirname $0)" && pwd )"  # absolutized and normalized
cd "${DIR}/../"

trap_func (){
    rc="$?"
    if ! [ "${rc}" = "0" ]; then
        clean_all trap
        echo "Error failed with exitcode ${rc}"  1>&2
        exit ${rc}
    fi
}

clean_all(){
    echo "Clean all initited by $1"
    trap - EXIT
    docker ps | grep -q "pilot-consul" && echo "killing pilot-consul" && docker kill pilot-consul
    echo "destroy kitchen"
    bundle exec kitchen destroy
}

start_consul(){
    if docker ps | grep -q "pilot-consul"
    then
        echo "pilot-consul allready running"
    else
        echo "Running consul"
        docker run -d --rm -p 8500:8500 -e CONSUL_BIND_INTERFACE=eth0 --name pilot-consul consul
    fi
}

start_testing(){
    start_consul
    bundle exec kitchen converge
    echo "Sleeping for 30"
    sleep 30
    bundle exec kitchen verify
    clean_all "start_testing"
}

if [ "$1" = "clean" ]; then
    clean_all "clean cli"
elif [ "$1" = "tests"  ]; then
    echo "* tests will always try to do clean up"
    trap trap_func EXIT
    start_testing
elif [ "$1" = "tests-debug" ]; then
    echo "* tests will skip clean up"
    start_testing
elif [ "$1" = "converge" ]; then
    start_consul
    echo "* running converge"
    bundle exec kitchen converge
elif [ "$1" = "verify" ]; then
    start_consul
    echo "* running verify"
    bundle exec kitchen verify
elif [ "$1" = "consul" ]; then
    start_consul
else
    echo "Unsported option '${1}' Supported options are:"
    echo " clean      : clean all containers."
    echo " tests      : Run tests"
    echo " consul     : Start consul"
    echo " converge   : Run converge only"
    echo " test-debug : Run tests, but don't destroy containers if they fail"
    exit 1
fi

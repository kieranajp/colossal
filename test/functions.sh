#!/bin/sh

case ${1} in
	remove-image)
        if [ -z "${2}" ]; then echo "Image name required"; exit 1; fi
        name="${2}"
        if [ -z "${3}" ]; then echo "Image version required"; exit 1; fi
        version="${3}"
        IMAGE=$(docker images | grep "${name}" | awk '{print $2}' | grep -w "${version}")
        if [ "${IMAGE}" = "${version}" ]; then
            echo " -> Removing ${name}:${version}"
            docker rmi "${name}:${version}"
        fi
    ;;
	stop-container)
        if [ -z "${2}" ]; then echo "Image name required"; exit 1; fi
        name="${2}"
        container=$(docker ps | grep -w "${name}" | awk '{ print $15 }')
        if [ "${container}" = "${name}" ]; then
            echo " -> Stopping ${name}"
            docker stop "${name}"
        fi
    ;;
	*)
        echo " -> \"${1}\" is INVALID FUNCTION!"
        exit 1
        ;;
esac
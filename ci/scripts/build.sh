#!/bin/sh
set -e

. "./ci/scripts/dockerStart.sh"

echo "* Installing GNU make"
apk add --update make

echo "* Installing docker-squash"
pip install docker-squash

# Building Colossal docker image
make build "CI_LABEL=${DOCKER_TAG}"

# Squashing layers
make squash "CI_LABEL=${DOCKER_TAG}"

# Pushing image
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASSWORD}" quay.io
make push-label "CI_LABEL=${DOCKER_TAG}"

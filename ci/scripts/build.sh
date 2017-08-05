#!/bin/sh
set -e

. "./ci/scripts/dockerStart.sh"

echo "* Installing GNU make"
apk add --update make

echo "* Installing docker-squash"
pip install docker-squash

echo "* Running bundle install"
bundle install

# Building Colossal docker image
bundle exec rspec build "CI_LABEL=${DOCKER_TAG}"

# Squashing layers
bundle exec rspec squash "CI_LABEL=${DOCKER_TAG}"

# Pushing image
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASSWORD}" quay.io
bundle exec rspec push-label "CI_LABEL=${DOCKER_TAG}"

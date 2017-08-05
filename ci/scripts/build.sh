#!/bin/sh
set -e

. "./ci/scripts/dockerStart.sh"

echo "* Installing docker-squash"
pip install docker-squash

echo "* Running bundle install"
bundle install

# Building Colossal docker image
CI_LABEL=${DOCKER_TAG} bundle exec rake build

# Squashing layers
CI_LABEL=${DOCKER_TAG} bundle exec rake squash

# Pushing image
docker login -u="${DOCKER_USER}" -p="${DOCKER_PASSWORD}" quay.io
CI_LABEL=${DOCKER_TAG} bundle exec rake push-label

# be nice and do clean up
CI_LABEL=${DOCKER_TAG} bundle exec rake clean-all

#!/bin/sh
set -e

. "./ci/scripts/dockerStart.sh"

echo "* pulling image ${DOCKER_TAG}"
docker pull "quay.io/ahelal/colossal:${DOCKER_TAG}"

echo "* linking dev"
docker tag "quay.io/ahelal/colossal:${DOCKER_TAG}" quay.io/ahelal/colossal:dev

# Building Colossal docker image
# cd "${source}" || echo "failed to cd into source. ${source}" || exit 1

echo "* Running bundle install"
bundle install

# Run the tests
CI_LABEL=${DOCKER_TAG} bundle exec rake tests

# be nice and do clean up
CI_LABEL=${DOCKER_TAG} bundle exec rake clean-all

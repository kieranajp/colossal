#!/bin/sh
set -e

MAIN_DIR="$(pwd)"

echo "* Building Colossal docker image"
cd "${source}" || echo "failed to cd into source. ${source}"
make build

echo "* Exporting Image"
cd "${MAIN_DIR}" || echo "failed to cd into main dir. ${MAIN_DIR}"
docker save quay.io/ahelal/colossal:dev | gzip > colossal_dev.tar.gz

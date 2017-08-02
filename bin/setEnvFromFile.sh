#!/bin/sh
set -e

# Set environmantal variable using container pilot


envFile="${1}"
tmpDir="$(mktemp -d 2> /dev/null || mktemp -d -t 'mytmpdir')"
tmpFile="${tmpDir}/app_env.sh"

if ! [ -f "${envFile}" ]; then
    echo "Not valid file path. ${envFile}"
    exit 1
fi

# Remove # and empty lines from envFile
grep  -v '^\s*#' "${envFile}" | grep -v '^\s*$' > "${tmpFile}"

#https://stackoverflow.com/a/12916758/3167035
while read -r line || [ -n "$line" ]; do
  # trim whitespace
  line=$(echo "${line}" | xargs)
  key=$(echo "${line}" | cut -f 1 -d "=")
  # Might need to remove print line and print only the key
  echo " * Setting up env ${key}"
  containerpilot -config /etc/containerpilot.json5 -putenv "${line}"
done < "${tmpFile}"

rm -rf "${tmpDir}"

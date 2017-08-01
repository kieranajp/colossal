#!/bin/sh
set -e

envFile="${1}"

if ! [ -f "${envFile}" ]; then
    echo "Not valid file path. ${envFile}"
    exit 1
fi

#https://stackoverflow.com/a/12916758/3167035
while read -r line || [ -n "$line" ]; do
  # ignore comments
  case "${line}" in
      \#*)
        echo " * Setting up env (ignoring comment)" ;;
      *)
        echo " * Setting up env ${line}"
        containerpilot -config /etc/containerpilot.json5 -putenv "${line}"
      ;;
  esac
done < "${envFile}"

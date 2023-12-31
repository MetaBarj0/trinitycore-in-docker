#!/bin/env sh

if [ -z "$@" ]; then
  echo 'You must specify a command to execute on the worldserver' >&2
  echo "Example: make exec cmd='server info'" >&2

  exit 1
fi

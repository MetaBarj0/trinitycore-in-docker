#!/bin/env bash

if [ -z "$1" ]; then
  echo 'You must specify a command to execute on the worldserver' >&2
  exit 1
fi

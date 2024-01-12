#!/bin/env bash

setup_ssh_keys() {
  cd

  mkdir -m 700 .ssh
  cat /run/secrets/ide_ssh_public_key > .ssh/id_rsa.pub
  cat /run/secrets/ide_ssh_secret_key > .ssh/id_rsa
  chmod -R 600 .ssh/id_rsa*

  cd -
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  setup_ssh_keys
  run_live_loop
}

main

shutdown() {
  echo 'Terminating ide gracefully...'

  exit 0
}

trap shutdown SIGTERM

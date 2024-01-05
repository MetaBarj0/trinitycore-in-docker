#!/bin/env bash

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  run_live_loop
}

main

shutdown() {
  echo 'Terminating ide gracefully...'

  exit 0
}

trap shutdown SIGTERM

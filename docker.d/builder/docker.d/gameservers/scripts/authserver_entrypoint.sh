#!/bin/sh

start_auth_server() {
  cd trinitycore/bin

  ./authserver &

  cd -
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  start_auth_server \
  && run_live_loop
}

main

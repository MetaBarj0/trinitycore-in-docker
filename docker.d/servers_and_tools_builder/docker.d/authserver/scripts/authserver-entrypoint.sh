#!/bin/sh

set -x

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
  start_auth_server
  run_live_loop
}

main

trap shutdown SIGTERM

kill_authserver_daemon() {
  echo Terminating gracefully authserver service...

  kill %1
}

shutdown() {
  kill_authserver_daemon

  exit 0
}

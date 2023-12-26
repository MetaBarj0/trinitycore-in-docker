#!env bash

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  run_live_loop
}

main

trap shutdown SIGTERM

shutdown() {
  echo Terminating gracefully servers_and_tools_builder service...

  exit 0
}

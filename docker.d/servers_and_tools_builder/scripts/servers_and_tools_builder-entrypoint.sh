#!env bash

create_auth_server() {
  :
}

create_world_server() {
  :
}

initialize_database() {
  :
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  initialize_database
  create_auth_server
  create_world_server
  run_live_loop
}

main

trap shutdown SIGTERM

shutdown() {
  echo Terminating gracefully servers_and_tools_builder service...

  exit 0
}

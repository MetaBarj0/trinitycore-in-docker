#! /bin/sh

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
  echo Terminating gracefully worldserver_console service...

  exit 0
}

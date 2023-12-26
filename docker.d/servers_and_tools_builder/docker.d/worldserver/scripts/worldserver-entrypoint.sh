#!/bin/bash

fetch_tdb_full() {
  cd downloads

  wget -c \
    https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.23061/TDB_full_world_335.23061_2023_06_14.7z \
    -O TDB_full_world_335.23061_2023_06_14.7z

  cd -
}

uncompress_tdb_full_to_worldserver() {
  cd downloads

  if ! [ -f TDB_full_world_335.23061_2023_06_14.sql ]; then
    p7zip -d -k TDB_full_world_335.23061_2023_06_14.7z
  fi

  if ! [ -L ../trinitycore/bin/TDB_full_world_335.23061_2023_06_14.sql ]; then
    ln -s $(pwd)/TDB_full_world_335.23061_2023_06_14.sql ../trinitycore/bin/
  fi

  cd -
}

run_worldserver() {
  trinitycore/bin/worldserver &
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  fetch_tdb_full
  uncompress_tdb_full_to_worldserver
  run_worldserver
  run_live_loop
}

main

trap shutdown SIGTERM

kill_worldserver_daemon() {
  echo Terminating gracefully worldserver service...

  kill %1
}

shutdown() {
  kill_worldserver_daemon

  exit 0
}

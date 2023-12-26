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

configure_worldserver() {
  cd trinitycore/etc

  cp -f worldserver.conf.dist worldserver.conf

  cd -

  cd diffs/configuration

  patch \
    /home/trinitycore/trinitycore/etc/worldserver.conf \
    worldserver.conf.diff

  cd -
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  fetch_tdb_full
  uncompress_tdb_full_to_worldserver
  configure_worldserver
  run_live_loop
}

main

#!/bin/bash

fetch_tdb_full() {
  cd downloads

  wget -c "${TDB_FULL_URI}" -o "${TDB_FULL_ARCHIVE_FILE_NAME}"

  cd -
}

uncompress_tdb_full_to_worldserver() {
  cd downloads

  if ! [ -f "${TDB_FULL_SQL_FILE_NAME}" ]; then
    p7zip -d -k "${TDB_FULL_ARCHIVE_FILE_NAME}"
  fi

  if ! [ -L "../trinitycore/bin/${TDB_FULL_SQL_FILE_NAME}" ]; then
    ln -s "$(pwd)/${TDB_FULL_SQL_FILE_NAME}" ../trinitycore/bin/
  fi

  cd -
}

create_bootstrap_admin_account() {
  cd sql

  local cmd='mysql -h databases -u trinity -ptrinity -b auth < create_bootstrap_admin_account.sql'

  until eval $cmd; do
    echo 'Creating bootstrap admin account...'

    sleep 1
  done

  cd -
}

set_realmlist_address() {
  local cmd="$(cat << EOF
mysql -h databases -u trinity -ptrinity -b auth -e
 'UPDATE realmlist set address = "${REALMLIST_ADDRESS}"
  WHERE id = 1;'
EOF
)"

  until eval $cmd; do
    echo 'Updating realmlist address...'

    sleep 1
  done
}

run_worldserver() {
  cd trinitycore/bin

  ./worldserver &

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
  run_worldserver
  create_bootstrap_admin_account
  set_realmlist_address
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

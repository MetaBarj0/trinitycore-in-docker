#!/bin/bash

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
    echo 'Updating realm address...'

    sleep 1
  done
}

update_realmlist_name() {
  if [ -z "${REALM_NAME}" ]; then
    return 0
  fi

  local cmd="$(cat << EOF
mysql -h databases -u trinity -ptrinity -b auth -e
 'UPDATE realmlist set name = "${REALM_NAME}"
  WHERE id = 1;'
EOF
    )"

  until eval $cmd; do
    echo 'Updating realm name...'

    sleep 1
  done
}

update_realmlist() {
  set_realmlist_address \
  && update_realmlist_name
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
  run_worldserver \
  && create_bootstrap_admin_account \
  && update_realmlist \
  && run_live_loop
}

main


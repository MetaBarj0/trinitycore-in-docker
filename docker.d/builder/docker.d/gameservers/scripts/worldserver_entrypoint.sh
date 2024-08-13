#!/bin/bash

query_latest_download_uri() {
  local query='map(select(.tag_name|startswith("TDB335"))) | sort_by(.created_at) | reverse | .[0].assets | .[0].browser_download_url'

  curl -s \
    https://api.github.com/repos/TrinityCore/TrinityCore/releases \
    | jq "${query}" \
    | sed 's/"//g'
}

extract_archive_name() {
  echo "${TDB_FULL_URI}" \
  | rev \
  | sed -E 's%(^[^/]+)/.+$%\1%' \
  | rev
}

fetch_tdb_full() {
  if [ "${TDB_FULL_URI}" = 'latest' ]; then
    TDB_FULL_URI="$(query_latest_download_uri)"
  fi

  local tdb_full_archive_file_name="$(extract_archive_name)"

  cd downloads

  wget -c "${TDB_FULL_URI}" -O "${tdb_full_archive_file_name}"

  cd -
}

extract_sql_name() {
  echo "$(extract_archive_name)" \
  | sed -E 's/\.7z$/.sql/'
}

uncompress_tdb_full_to_worldserver() {
  local tdb_full_archive_file_name="$(extract_archive_name)"
  local tdb_full_sql_file_name="$(extract_sql_name)"

  cd downloads

  if [ ! -f "${tdb_full_sql_file_name}" ]; then
    p7zip -d -k "${tdb_full_archive_file_name}"
  fi

  if [ ! -L "../trinitycore/bin/${tdb_full_sql_file_name}" ]; then
    ln -s "$(pwd)/${tdb_full_sql_file_name}" ../trinitycore/bin/
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
  fetch_tdb_full \
  && uncompress_tdb_full_to_worldserver \
  && run_worldserver \
  && create_bootstrap_admin_account \
  && update_realmlist \
  && run_live_loop
}

main

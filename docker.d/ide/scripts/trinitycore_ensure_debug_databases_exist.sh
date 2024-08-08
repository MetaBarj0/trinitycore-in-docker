get_real_source_directory() {
  echo "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

get_real_install_directory() {
  echo "${TRINITYCORE_INSTALL_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

patch_create_mysql() {
  # EXPLAIN: there are trailing characters, necessary for the diff
  patch \
    "$(get_real_source_directory)/sql/create/create_mysql.sql" \
    -o "${USER_HOME_DIR}/create_mysql.sql" << EOF
1c1
< CREATE USER 'trinity'@'localhost' IDENTIFIED BY 'trinity' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
---
> CREATE DATABASE IF NOT EXISTS \`${DEBUG_WORLD_DATABASE_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
3c3
< GRANT USAGE ON * . * TO 'trinity'@'localhost';
---
> CREATE DATABASE IF NOT EXISTS \`${DEBUG_CHARACTERS_DATABASE_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
5c5
< CREATE DATABASE \`world\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
---
> CREATE DATABASE IF NOT EXISTS \`${DEBUG_AUTH_DATABASE_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
7c7
< CREATE DATABASE \`characters\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
---
> GRANT ALL PRIVILEGES ON \`${DEBUG_WORLD_DATABASE_NAME}\` . * TO 'trinity'@'11.12.13.%' WITH GRANT OPTION;
9c9
< CREATE DATABASE \`auth\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
---
> GRANT ALL PRIVILEGES ON \`${DEBUG_CHARACTERS_DATABASE_NAME}\` . * TO 'trinity'@'11.12.13.%' WITH GRANT OPTION;
11,15c11
< GRANT ALL PRIVILEGES ON \`world\` . * TO 'trinity'@'localhost' WITH GRANT OPTION;
<	
< GRANT ALL PRIVILEGES ON \`characters\` . * TO 'trinity'@'localhost' WITH GRANT OPTION;
<	
< GRANT ALL PRIVILEGES ON \`auth\` . * TO 'trinity'@'localhost' WITH GRANT OPTION;
---
> GRANT ALL PRIVILEGES ON \`${DEBUG_AUTH_DATABASE_NAME}\` . * TO 'trinity'@'11.12.13.%' WITH GRANT OPTION;
EOF
}

create_databases_if_not_exist() {
  local cmd='mariadb -h databases -u root -proot < '"${USER_HOME_DIR}/create_mysql.sql"

  while ! eval ${cmd}; do
    sleep 1;
  done
}

set_realmlist_id() {
  mariadb -h databases -u trinity -ptrinity << EOF
UPDATE ${DEBUG_AUTH_DATABASE_NAME}.realmlist
SET id = ${DEBUG_REALM_ID}
WHERE id = 1;
EOF
}

set_realmlist_address() {
  mariadb -h databases -u trinity -ptrinity << EOF
UPDATE ${DEBUG_AUTH_DATABASE_NAME}.realmlist
SET address = "${DEBUG_REALMLIST_ADDRESS}",
    port = ${DEBUG_WORLDSERVER_PORT}
WHERE id = ${DEBUG_REALM_ID};
EOF
}

update_realm_name_if_necessary() {
  if [ -z "${DEBUG_REALM_NAME}" ]; then
    return 0
  fi

  mariadb -h databases -u trinity -ptrinity << EOF
UPDATE ${DEBUG_AUTH_DATABASE_NAME}.realmlist
SET name = "${DEBUG_REALM_NAME}"
WHERE id = ${DEBUG_REALM_ID};
EOF
}

update_realmlist_table_if_necessary() {
  set_realmlist_id \
  && set_realmlist_address \
  && update_realm_name_if_necessary
}

rm_patched_sql_file() {
  rm -f "${USER_HOME_DIR}/create_mysql.sql"
}

extract_archive_name_from_uri() {
  local uri="$1"

  echo "${uri}" \
  | rev \
  | sed -E 's%(^[^/]+)/.+$%\1%' \
  | rev
}

query_latest_download_uri() {
  local query='map(select(.tag_name|startswith("TDB335"))) | sort_by(.created_at) | reverse | .[0].assets | .[0].browser_download_url'

  curl -s \
    https://api.github.com/repos/TrinityCore/TrinityCore/releases \
    | jq "${query}" \
    | sed 's/"//g'
}

fetch_db_release() {
  local tdb_full_uri="${TDB_FULL_URI}"

  if [ "${tdb_full_uri}" = 'latest' ]; then
    tdb_full_uri="$(query_latest_download_uri)"
  fi

  local tdb_full_archive_file_name="$(extract_archive_name_from_uri "${tdb_full_uri}")"

  wget -q -c \
    "${tdb_full_uri}" \
    -O "$(get_real_install_directory)/bin/${tdb_full_archive_file_name}"

  echo "${tdb_full_uri}"
}

extract_sql_name() {
  local archive_file_name="$1"

  echo "${archive_file_name}" \
  | sed -E 's/\.7z$/.sql/'
}

extract_db_release() {
  while read input; do
    local tdb_full_archive_file_name="$(get_real_install_directory)/bin/$(extract_archive_name_from_uri "${input}")"
    local tdb_full_sql_file_name="$(extract_sql_name "${tdb_full_archive_file_name}")"

    if [ ! -f "${tdb_full_sql_file_name}" ]; then
      cd "$(get_real_install_directory)/bin"

      p7zip -d -k "${tdb_full_archive_file_name}"

      cd - > /dev/null
    fi

    return $?
  done
}

install_db_release() {
  fetch_db_release \
  | extract_db_release
}

main() {
  patch_create_mysql \
  && create_databases_if_not_exist \
  && update_realmlist_table_if_necessary \
  && rm_patched_sql_file \
  && install_db_release
}

main

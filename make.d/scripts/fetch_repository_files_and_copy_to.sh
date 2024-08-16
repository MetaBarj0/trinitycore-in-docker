compute_template_uri() {
  if [ -n "${REPOSITORY_SHA}" ]; then
    echo "${RAW_REPOSITORY_URI}"/"${REPOSITORY_SHA}"
  else
    echo "${RAW_REPOSITORY_URI}"/"${REPOSITORY_REV}"
  fi
}

fetch_repository_file_and_copy_to() {
  local uri="$(compute_template_uri)"
  local template="$1"
  local file="$2"

  curl "$uri"/"$template" -o "$file"
}

fetch_authserver_configuration() {
  local destination_directory="$1"

  if [ -f "${destination_directory}/authserver.conf" ]; then
    return 0
  fi

  fetch_repository_file_and_copy_to \
    'src/server/authserver/authserver.conf.dist' \
    "${destination_directory}/authserver.conf"
}

fetch_worldserver_configuration() {
  local destination_directory="$1"

  if [ -f "${destination_directory}/worldserver.conf" ]; then
    return 0
  fi

  fetch_repository_file_and_copy_to \
    'src/server/worldserver/worldserver.conf.dist' \
    "${destination_directory}/worldserver.conf"
}

fetch_sql_create_script() {
  local destination_directory="$1"

  if [ -f "${destination_directory}/create_mysql.sql" ]; then
    return 0
  fi

  fetch_repository_file_and_copy_to \
    'sql/create/create_mysql.sql' \
    "${destination_directory}/create_mysql.sql"
}

fetch_repository_files_and_copy_to() {
  local destination_directory="$1"

  fetch_authserver_configuration "${destination_directory}" \
  && fetch_worldserver_configuration "${destination_directory}" \
  && fetch_sql_create_script "${destination_directory}"
}

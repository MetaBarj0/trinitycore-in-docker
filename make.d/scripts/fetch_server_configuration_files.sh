check_file_paths() {
  if [ -z "${AUTHSERVER_CONF_PATH}" ] || [ -z "${WORLDSERVER_CONF_PATH}" ]; then
    cat << EOF >&2
    FATAL
    AUTHSERVER_CONF_PATH variable must be set
    WORLDSERVER_CONF_PATH variable must be set
    Edit your Makefile.env file to set them
EOF

    exit 1
  fi
}

compute_template_uri() {
  if ! [ -z "${REPOSITORY_SHA}" ]; then
    echo "${RAW_REPOSITORY_URI}"/"${REPOSITORY_SHA}"
  else
    echo "${RAW_REPOSITORY_URI}"/"${REPOSITORY_REV}"
  fi
}

fetch_template_and_copy_to() {
  local uri="$(compute_template_uri)"
  local template="$1"
  local file="$2"

  curl "$uri"/"$template" -o "$file"
}

fetch_authserver_configuration() {
  if [ -f "${AUTHSERVER_CONF_PATH}" ]; then
    return 0
  fi

  fetch_template_and_copy_to \
    'src/server/authserver/authserver.conf.dist' \
    "${AUTHSERVER_CONF_PATH}"
}

fetch_worldserver_configuration() {
  if [ -f "${WORLDSERVER_CONF_PATH}" ]; then
    return 0
  fi

  fetch_template_and_copy_to \
    'src/server/worldserver/worldserver.conf.dist' \
    "${WORLDSERVER_CONF_PATH}"
}

check_file_paths
fetch_authserver_configuration
fetch_worldserver_configuration

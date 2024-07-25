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

fetch_server_configuration_files() {
  check_file_paths \
  && fetch_authserver_configuration \
  && fetch_worldserver_configuration
}

print_post_prepare_message() {
cat << EOF
Preparation phase is done.
You may need to manual setup some stuff if not already done:

- Makefile.env
  - Make sure every variables have a value
- Makefile.maintainer.env
  - Be aware that default values can be modified according your needs
- ${AUTHSERVER_CONF_PATH}
  - Feel free to modify whatever you want in this file but...
  - Keep in mind some values may be modified for the server to work.
    - More details in the 'Makefile.env' file in commented section for the
      AUTHSERVER_CONF_PATH variable
- ${WORLDSERVER_CONF_PATH}
  - Feel free to modify whatever you want in this file but...
  - Keep in mind some values may be modified for the server to work.
    - More details in the 'Makefile.env' file in commented section for the
      WORLDSERVER_CONF_PATH variable
EOF
}

main() {
  fetch_server_configuration_files \
  && print_post_prepare_message
}

main

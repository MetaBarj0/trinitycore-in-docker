. make.d/scripts/fetch_repository_files_and_copy_to.sh

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
  check_file_paths \
  && fetch_repository_files_and_copy_to . \
  && print_post_prepare_message
}

main

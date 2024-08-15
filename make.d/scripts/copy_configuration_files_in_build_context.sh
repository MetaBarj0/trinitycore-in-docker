# TODO: rename script file and refacto to make more generic, get inspired by
#       archive.sh
copy_configuration_files_in_build_context() {
  local build_context="$1"

  cp \
    "${WORLDSERVER_CONF_PATH}" \
    "${AUTHSERVER_CONF_PATH}" \
    Makefile.env \
    Makefile.maintainer.env \
    "${build_context}"
}

copy_create_mysql_in_build_context() {
  local build_context="$1"

  cp \
    create_mysql.sql \
    "${build_context}"
}

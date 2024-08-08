copy_configuration_files_in_build_context() {
  local build_context="$1"

  cp \
    "${WORLDSERVER_CONF_PATH}" \
    "${AUTHSERVER_CONF_PATH}" \
    Makefile.env \
    Makefile.maintainer.env \
    "${build_context}"
}


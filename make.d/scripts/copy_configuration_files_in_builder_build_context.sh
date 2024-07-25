copy_configuration_files_in_builder_build_context() {
  cp \
    "${WORLDSERVER_CONF_PATH}" \
    "${AUTHSERVER_CONF_PATH}" \
    Makefile.env \
    Makefile.maintainer.env \
    docker.d/builder/
}


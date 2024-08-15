export_volume_with_image_and_shell() {
  local image="$1"
  local shell="$2"
  local volume="$3"

  local command="cd /${volume}
find . -maxdepth 1 ! -name '.' | xargs tar -cf /host/${volume}.tar"

  docker run \
    --rm \
    -u root \
    -v "${volume}":"/${volume}" \
    -v .:/host \
    "${image}" \
    "${shell}" -c "${command}"
}

export_databases_data_volume() {
  echo '    exporting databases_data volume...'

  export_volume_with_image_and_shell \
    "${NAMESPACE}.databases:${DATABASES_VERSION}" \
    '/bin/ash' \
    "${COMPOSE_PROJECT_NAME}_databases_data"
}

append_inner_archive_to_outer_archive() {
  local inner_archive="$1"
  local outer_archive="$2"

  tar -rf "${outer_archive}" "${inner_archive}" \
  && rm -rf "${inner_archive}"
}

export_client_data_volume() {
  echo '    exporting client_data volume...'

  export_volume_with_image_and_shell \
    "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}" \
    '/bin/bash' \
    "${COMPOSE_PROJECT_NAME}_client_data"
}

export_volumes() {
  echo '  exporting volumes...'

  export_databases_data_volume \
  && append_inner_archive_to_outer_archive "${COMPOSE_PROJECT_NAME}_databases_data.tar" volumes.tar \
  && export_client_data_volume \
  && append_inner_archive_to_outer_archive "${COMPOSE_PROJECT_NAME}_client_data.tar" volumes.tar \
  && append_inner_archive_to_outer_archive volumes.tar "${NAMESPACE}.${COMPOSE_PROJECT_NAME}.tar"
}

export_databases_image() {
  echo '    exporting databases image...'

  docker save \
    -o "${NAMESPACE}.databases:${DATABASES_VERSION}.tar" \
    "${NAMESPACE}.databases:${DATABASES_VERSION}"
}

export_gameservers_image() {
  echo '    exporting gameservers image...'

  docker save \
    -o "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}.tar" \
    "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}"
}

export_worldserver_remote_access_image() {
  echo '    exporting worldserver_remote_access image...'

  docker save \
    -o "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}.tar" \
    "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}"
}

export_images() {
  echo '  exporting images...'

  export_databases_image \
  && append_inner_archive_to_outer_archive "${NAMESPACE}.databases:${DATABASES_VERSION}.tar" images.tar \
  && export_gameservers_image \
  && append_inner_archive_to_outer_archive "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}.tar" images.tar \
  && export_worldserver_remote_access_image \
  && append_inner_archive_to_outer_archive "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}.tar" images.tar \
  && append_inner_archive_to_outer_archive images.tar "${NAMESPACE}.${COMPOSE_PROJECT_NAME}.tar"
}

main() {
  echo "starting ${NAMESPACE}.${COMPOSE_PROJECT_NAME} project export..."

  export_volumes \
  && export_images
}

main

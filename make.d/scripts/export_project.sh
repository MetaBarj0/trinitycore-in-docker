export_databases_image() {
  echo '  exporting databases image...'

  docker save \
    -o "./${NAMESPACE}.databases:${DATABASES_VERSION}.tar" \
    "${NAMESPACE}.databases:${DATABASES_VERSION}"
}

export_gameservers_image() {
  echo '  exporting gameservers image...'

  docker save \
    -o "./${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}.tar" \
    "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}"
}

export_worldserver_remote_access_image() {
  echo '  exporting worldserver_remote_access image...'

  docker save \
    -o "./${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}.tar" \
    "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}"
}

archive_images() {
  echo '  archiving images...'

  tar cf \
    images.tar \
    "${NAMESPACE}.databases:${DATABASES_VERSION}.tar" \
    "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}.tar" \
    "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}.tar" \
  && rm -f \
    "${NAMESPACE}.databases:${DATABASES_VERSION}.tar" \
    "${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}.tar" \
    "${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}.tar"
}

export_images() {
  echo 'exporting images...'

  export_databases_image \
  && export_gameservers_image \
  && export_worldserver_remote_access_image \
  && archive_images
}

export_volume() {
  local volume="$1"

  local command="cd /${volume}
find . -maxdepth 1 ! -name '.' | xargs tar cf /host/${volume}.tar"

  docker run \
    --rm \
    -v "${volume}":"/${volume}" \
    -v .:/host \
    alpine:edge \
    ash -c "${command}"
}

export_databases_data_volume() {
  echo '  exporting databases_data volume...'

  export_volume "${COMPOSE_PROJECT_NAME}_databases_data"
}

export_client_data_volume() {
  echo '  exporting client_data volume...'

  export_volume "${COMPOSE_PROJECT_NAME}_client_data"
}

archive_volumes() {
  echo '  archiving volumes...'

  tar cf \
    volumes.tar \
    "${COMPOSE_PROJECT_NAME}_databases_data.tar" \
    "${COMPOSE_PROJECT_NAME}_client_data.tar" \
  && rm -f \
    "${COMPOSE_PROJECT_NAME}_databases_data.tar" \
    "${COMPOSE_PROJECT_NAME}_client_data.tar"
}

export_volumes() {
  echo 'exporting volumes...'

  export_databases_data_volume \
  && export_client_data_volume \
  && archive_volumes
}

package() {
  local package_name="${NAMESPACE}.${COMPOSE_PROJECT_NAME}.tar"

  echo "packaging project in $(pwd)/${package_name}..."

  tar cf \
    "${package_name}" \
    "images.tar" \
    "volumes.tar" \
  && rm -f \
    "images.tar" \
    "volumes.tar"
}

main() {
  export_images \
  && export_volumes \
  && package
}

main

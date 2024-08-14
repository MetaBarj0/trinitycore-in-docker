#!/bin/env bash
patch_authserver_configuration() {
  cd docker.d/gameservers/patches/configuration

  patch \
    ../../authserver.conf \
    authserver.conf.diff

  cd -
}

copy_server_configuraton_file_to_build_context() {
  local conf_file_name="$1"

  local container_id=$(docker run --rm -it -d ${NAMESPACE}.gameservers:${GAMESERVERS_VERSION} bash)

  docker cp \
    "${container_id}:/home/trinitycore/trinitycore/etc/${conf_file_name}" \
    docker.d/gameservers

  docker kill ${container_id} > /dev/null
}

prepare_authserver_configuration() {
  copy_server_configuraton_file_to_build_context authserver.conf \
  && patch_authserver_configuration
}

patch_worldserver_configuration() {
  cd docker.d/gameservers/patches/configuration

  patch \
    ../../worldserver.conf \
    worldserver.conf.diff

  cd -
}

prepare_worldserver_configuration() {
  copy_server_configuraton_file_to_build_context worldserver.conf \
  && patch_worldserver_configuration
}

build_gameservers_image() {
  docker build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg GAMESERVERS_VERSION=${GAMESERVERS_VERSION} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/gameservers/gameservers.Dockerfile \
    -t ${NAMESPACE}.gameservers:${GAMESERVERS_VERSION} \
    docker.d/gameservers
}

create_gameservers_image() {
  prepare_worldserver_configuration \
  && prepare_authserver_configuration \
  && build_gameservers_image
}

has_gameservers_image_not_been_released_yet() {
  local release="$(docker inspect --type image \
    ${NAMESPACE}.gameservers:${GAMESERVERS_VERSION} \
    -f '{{ .Config.Labels.release }}')"

  [ "${release}" != 'yes' ]
}

main() {
  if has_gameservers_image_not_been_released_yet; then
    create_gameservers_image
  fi
}

main

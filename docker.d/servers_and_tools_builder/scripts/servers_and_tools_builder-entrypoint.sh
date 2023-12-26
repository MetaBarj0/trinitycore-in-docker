#!/bin/env bash

set -e

create_auth_server_image() {
  echo Building authserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    -f docker.d/authserver/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d/authserver
}

generate_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf Buildings Cameras dbc maps vmaps mmaps
  rm -f mapextractor vmap4extractor vmap4assembler mmaps_generator

  cp /home/trinitycore/trinitycore/bin/mapextractor .
  ./mapextractor

  cp /home/trinitycore/trinitycore/bin/vmap4extractor .
  ./vmap4extractor

  cp /home/trinitycore/trinitycore/bin/vmap4assembler .
  mkdir vmaps
  ./vmap4assembler Buildings vmaps

  cp /home/trinitycore/trinitycore/bin/mmaps_generator .

  cd -
}

build_worldserver_image() {
  echo Building worldserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    --build-arg CLIENT_PATH=${CLIENT_PATH} \
    -f docker.d/worldserver/worldserver.Dockerfile \
    -t ${WORLDSERVER_IMAGE_TAG} \
    docker.d/worldserver
}

create_world_server_image() {
  generate_client_data
  build_worldserver_image
}

main() {
  create_auth_server_image
  create_world_server_image
}

main

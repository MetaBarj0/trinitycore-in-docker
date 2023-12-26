#!/bin/env bash

set -e

create_auth_server() {
  echo Building authserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    -f docker.d/authserver/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d/authserver
}

create_world_server() {
  echo Building worldserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    -f docker.d/worldserver/worldserver.Dockerfile \
    -t ${WORLDSERVER_IMAGE_TAG} \
    docker.d/worldserver
}

main() {
  create_auth_server
  create_world_server
}

main

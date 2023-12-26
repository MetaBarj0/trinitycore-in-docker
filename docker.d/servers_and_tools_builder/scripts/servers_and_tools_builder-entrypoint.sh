#!/bin/env bash

set -e

create_auth_server() {
  echo Building authserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    -f docker.d/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d
}

create_world_server() {
  :
}

main() {
  create_auth_server
  create_world_server
}

main

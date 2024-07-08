#!/bin/env sh

if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"

# TODO: replace '-' with '_'
  docker build \
    --platform $TARGET_PLATFORM \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/common/debian-12-slim-upgraded.Dockerfile \
    -t "${NAMESPACE}".debian"${platform_tag}":12-slim-upgraded \
    docker.d/common
else
  docker build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/common/debian-12-slim-upgraded.Dockerfile \
    -t "${NAMESPACE}".debian:12-slim-upgraded \
    docker.d/common
fi


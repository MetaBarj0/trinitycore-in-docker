#!/bin/env sh

if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"

  docker build \
    --platform $TARGET_PLATFORM \
    -f docker.d/common/debian-12-slim-upgraded.Dockerfile \
    -t "${NAMESPACE}".debian"${platform_tag}":12-slim-upgraded \
    docker.d/common
else
  docker build \
    -f docker.d/common/debian-12-slim-upgraded.Dockerfile \
    -t "${NAMESPACE}".debian:12-slim-upgraded \
    docker.d/common
fi


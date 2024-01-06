#!/bin/env sh

if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"

  docker build \
    --platform $TARGET_PLATFORM \
    --build-arg PLATFORM_TAG="${platform_tag}" \
    -f docker.d/common/serverbase.Dockerfile \
    -t ${NAMESPACE}.serverbase"${platform_tag}" \
    docker.d/common
else
  docker build \
    -f docker.d/common/serverbase.Dockerfile \
    -t ${NAMESPACE}.serverbase \
    docker.d/common
fi


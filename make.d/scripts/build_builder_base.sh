#!/bin/env sh

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  docker build \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER_HOME_DIR=/root \
    -f docker.d/common/builderbase.Dockerfile \
    -t ${NAMESPACE}.builderbase \
    docker.d/common
fi

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  docker build \
    --build-arg DOCKER_GID=$(getent group docker | cut -d : -f 3) \
    --build-arg DOCKER_UID=$(id -u) \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER_HOME_DIR=/home/docker \
    -f docker.d/common/builderbase.Dockerfile \
    -t ${NAMESPACE}.builderbase \
    docker.d/common
fi

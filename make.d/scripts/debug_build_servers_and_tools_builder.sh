#!/bin/env sh

export BUILDX_EXPERIMENTAL=1

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
	docker buildx debug build \
    --build-arg DOCKER_GID=$(getent group docker | cut -d : -f 3) \
    --build-arg DOCKER_UID=$(id -u) \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=docker \
    --build-arg USER_HOME_DIR=/home/docker \
    -f docker.d/servers_and_tools_builder/servers_and_tools_builder.Dockerfile \
    docker.d/servers_and_tools_builder
else
	docker buildx build \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=root \
    --build-arg USER_HOME_DIR=/root \
    --invoke /bin/bash \
    -f docker.d/servers_and_tools_builder/servers_and_tools_builder.Dockerfile \
    docker.d/servers_and_tools_builder
fi

#!/bin/env sh

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  docker compose build builder \
    --build-arg USER=docker \
    --build-arg USER_HOME_DIR=/home/docker
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  docker compose build builder \
    --build-arg USER=root \
    --build-arg USER_HOME_DIR=/root
fi

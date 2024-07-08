if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  docker compose build \
    --build-arg USER=docker \
    --build-arg USER_HOME_DIR=/home/docker \
    builder
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  docker compose build \
    --build-arg USER=root \
    --build-arg USER_HOME_DIR=/root \
    builder
fi

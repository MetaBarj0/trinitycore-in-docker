# TODO: simplify, conditioning variables only
if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  docker compose -f docker.d/docker-compose.yml build \
    --build-arg USER=docker \
    --build-arg USER_GID=$(getent group docker | cut -d : -f 3) \
    --build-arg USER_HOME_DIR=/home/docker \
    --build-arg USER_UID=$(id -u) \
    builder
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  docker compose -f docker.d/docker-compose.yml build \
    --build-arg USER=root \
    --build-arg USER_GID=0 \
    --build-arg USER_HOME_DIR=/root \
    --build-arg USER_UID=0 \
    builder
fi

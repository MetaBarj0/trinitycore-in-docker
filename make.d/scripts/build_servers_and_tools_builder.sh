# TODO: take only 0 and 1 as valid values
if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  docker compose build servers_and_tools_builder \
    --build-arg DOCKER_GID=$(getent group docker | cut -d : -f 3) \
    --build-arg DOCKER_UID=$(id -u) \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=docker \
    --build-arg USER_HOME_DIR=/home/docker
else
  docker compose build servers_and_tools_builder \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=root \
    --build-arg USER_HOME_DIR=/root
fi

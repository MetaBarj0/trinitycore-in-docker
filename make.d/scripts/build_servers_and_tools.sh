set -e

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  export USER_HOME_DIR=${IDE_USER_HOME_DIR}
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  export USER_HOME_DIR=/root
fi

docker compose -f docker.d/docker-compose.yml up builder
docker compose -f docker.d/docker-compose.yml down builder

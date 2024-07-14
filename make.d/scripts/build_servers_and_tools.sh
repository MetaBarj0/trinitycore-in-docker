set -e

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  export USER_HOME_DIR=/home/docker
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  export USER_HOME_DIR=/root
fi

docker compose up builder
docker compose down builder

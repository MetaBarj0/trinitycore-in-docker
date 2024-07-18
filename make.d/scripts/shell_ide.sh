if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  USER_GID=$(getent group docker | cut -d : -f 3)
  USER_UID=$(id -u)
  USER_HOME_DIR=/home/docker
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  USER_GID=0
  USER_UID=0
  USER_HOME_DIR=/root
fi

docker exec \
  --env USER_GID=${USER_GID} \
  --env USER_HOME_DIR=${USER_HOME_DIR} \
  --env USER_UID=${USER_UID} \
  -it ${COMPOSE_PROJECT_NAME}_ide_container bash

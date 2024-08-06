main() {
  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    local user_gid=$(getent group docker | cut -d : -f 3)
    local user_home_dir=/home/docker
    local user_uid=$(id -u)
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    local user_gid=0
    local user_home_dir=/root
    local user_uid=0
  fi

  docker exec \
    --env USER_GID=${user_gid} \
    --env USER_HOME_DIR=${user_home_dir} \
    --env USER_UID=${user_uid} \
    -it ${COMPOSE_PROJECT_NAME}_ide_container bash
}

main

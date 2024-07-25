main() {
  local user
  local user_gid
  local user_home_dir
  local user_uid

  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    user=docker
    user_gid=$(getent group docker | cut -d : -f 3)
    user_home_dir=/home/docker
    user_uid=$(id -u)
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    user=root
    user_gid=0
    user_home_dir=/root
    user_uid=0
  fi

  docker compose -f docker.d/docker-compose.yml build \
    --build-arg USER=${user} \
    --build-arg USER_GID=${user_gid} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    --build-arg USER_UID=${user_uid} \
    builder
}

main

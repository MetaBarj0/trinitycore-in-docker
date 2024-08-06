main() {
  local platform_tag

  if ! [ -z "${TARGET_PLATFORM}" ] && [ 'local' != "${TARGET_PLATFORM}" ];then
    target_platform="$TARGET_PLATFORM"
    platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
  fi

  local user
  local user_home_dir

  # TODO: change user name for ide service
  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    user=docker
    user_home_dir=/home/docker
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    user=root
    user_home_dir=/root
  fi

  docker compose \
    -f docker.d/docker-compose.yml \
    build \
    --build-arg CLIENT_PATH="${CLIENT_PATH}" \
    --build-arg PLATFORM_TAG=${platform_tag} \
    --build-arg USER=${user} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    ide 
}

main

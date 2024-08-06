main() {
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

  docker build \
    --build-arg CLIENT_PATH="${CLIENT_PATH}" \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg IDE_NEOVIM_REV=${IDE_NEOVIM_REV} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg NODEJS_VER=${NODEJS_VER} \
    --build-arg USER=${user} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    -f docker.d/ide/ide.Dockerfile \
    -t ${NAMESPACE}.ide:${IDE_VERSION} \
    docker.d/ide
}

main

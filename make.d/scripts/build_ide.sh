main() {
  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    local user=${SHELL_USER_NAME}
    local user_home_dir=${SHELL_USER_HOME_DIR}
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    local user=root
    local user_home_dir=/root
  fi

  docker build \
    --build-arg CLIENT_PATH="${CLIENT_PATH}" \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NEOVIM_REV=${NEOVIM_REV} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg NODEJS_VER=${NODEJS_VER} \
    --build-arg USER=${user} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    -f docker.d/ide/ide.Dockerfile \
    -t ${NAMESPACE}.ide:${IDE_VERSION} \
    docker.d/ide
}

main

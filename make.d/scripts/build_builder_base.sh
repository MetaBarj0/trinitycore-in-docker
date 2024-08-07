main() {
  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    local user=${IDE_USER_NAME}
    local user_gid=$(getent group docker | cut -d : -f 3)
    local user_uid=$(id -u)
    local user_home_dir=${IDE_USER_HOME_DIR}
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    local user=root
    local user_gid=0
    local user_uid=0
    local user_home_dir=/root
  fi

  docker build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=${user} \
    --build-arg USER_GID=${user_gid} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    --build-arg USER_UID=${user_uid} \
    -f docker.d/builderbase.Dockerfile \
    -t ${NAMESPACE}.builderbase \
    docker.d
}

main

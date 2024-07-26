main() {
  local platform_tag=
  local target_platform=local

  if [ ! -z "${TARGET_PLATFORM}" ] && [ 'local' != "${TARGET_PLATFORM}" ]; then
    platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
    target_platform=${TARGET_PLATFORM}
  fi

  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    docker_gid=$(getent group docker | cut -d : -f 3)
    docker_uid=$(id -u)
    user_home_dir=/home/docker
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    docker_gid=0
    docker_uid=0
    user_home_dir=/root
  fi

  docker build \
    --platform ${target_platform} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg DOCKER_GID=${docker_gid} \
    --build-arg DOCKER_UID=${docker_uid} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg PLATFORM_TAG=${platform_tag} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    -f docker.d/builderbase.Dockerfile \
    -t ${NAMESPACE}.builderbase${platform_tag} \
    docker.d
}

main

. make.d/scripts/copy_configuration_files_in_builder_build_context.sh

main() {
  copy_configuration_files_in_builder_build_context

  export BUILDX_EXPERIMENTAL=1

  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
      local user=${SHELL_USER_NAME}
      local user_gid=$(getent group docker | cut -d : -f 3)
      local user_home_dir=${IDE_USER_HOME_DIR}
      local user_uid=$(id -u)
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
      local user=root
      local user_gid=0
      local user_home_dir=/root
      local user_uid=0
  fi

  docker buildx debug build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
    --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
    --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
    --build-arg USER=${user} \
    --build-arg USER_GID=${user_gid} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    --build-arg USER_UID=${user_uid} \
    -f docker.d/builder/builder.Dockerfile \
    --ssh=default \
    -t ${NAMESPACE}.builder:${BUILDER_VERSION} \
    docker.d/builder
}

main

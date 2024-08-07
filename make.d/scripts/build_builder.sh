. ./make.d/scripts/copy_configuration_files_in_builder_build_context.sh

copy_scripts_in_builder_build_context() {
  cp $@ docker.d/builder
}

main() {
  copy_configuration_files_in_builder_build_context \
  && copy_scripts_in_builder_build_context make.d/scripts/archive.sh

  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    local user=${SHELL_USER_NAME}
    local user_gid=$(getent group docker | cut -d : -f 3)
    local user_home_dir=${SHELL_USER_HOME_DIR}
    local user_uid=$(id -u)
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    local user=root
    local user_gid=0
    local user_home_dir=/root
    local user_uid=0
  fi

  docker build \
    --ssh default \
    --build-arg AUTHSERVER_VERSION=${AUTHSERVER_VERSION} \
    --build-arg BUILDER_VERSION=${BUILDER_VERSION} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
    --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
    --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
    --build-arg USER=${user} \
    --build-arg USER_GID=${user_gid} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    --build-arg USER_UID=${user_uid} \
    --build-arg WORLDSERVER_VERSION=${WORLDSERVER_VERSION} \
    -t ${NAMESPACE}.builder:${BUILDER_VERSION} \
    -f docker.d/builder/builder.Dockerfile \
    docker.d/builder
}

main

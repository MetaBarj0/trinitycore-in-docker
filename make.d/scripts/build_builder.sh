. ./make.d/scripts/copy_files_in_build_context.sh

main() {
  copy_files_in_build_context \
    "${WORLDSERVER_CONF_PATH}" \
    "${AUTHSERVER_CONF_PATH}" \
    Makefile.env \
    Makefile.maintainer.env \
    make.d/scripts/archive.sh \
    'docker.d/builder'

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
    --build-arg BUILDER_VERSION=${BUILDER_VERSION} \
    --build-arg BUILDERBASE_VERSION=${BUILDERBASE_VERSION} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg GAMESERVERS_VERSION=${GAMESERVERS_VERSION} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
    --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
    --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
    --build-arg USER=${user} \
    --build-arg USER_GID=${user_gid} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    --build-arg USER_UID=${user_uid} \
    -t ${NAMESPACE}.builder:${BUILDER_VERSION} \
    -f docker.d/builder/builder.Dockerfile \
    docker.d/builder
}

main

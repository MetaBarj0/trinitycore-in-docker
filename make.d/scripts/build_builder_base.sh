platform_arg=
build_arg_arg=
platform_tag=

if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
  platform_arg='--platform '$TARGET_PLATFORM
  build_arg_arg='--build-arg PLATFORM_TAG='"${platform_tag}"
fi

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  build_arg_arg="$(cat << EOF
  ${build_arg_arg} \
  --build-arg DOCKER_GID=$(getent group docker | cut -d : -f 3) \
  --build-arg DOCKER_UID=$(id -u) \
  --build-arg USER_HOME_DIR=/home/docker
EOF
  )"
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  build_arg_arg="$(cat << EOF
  ${build_arg_arg} \
  --build-arg USER_HOME_DIR=/root
EOF
  )"
fi

build_command="$(cat << EOF
docker build \
    ${platform_arg} \
    ${build_arg_arg} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    -f docker.d/common/builderbase.Dockerfile \
    -t ${NAMESPACE}.builderbase${platform_tag} \
    docker.d/common
EOF
)"

eval ${build_command}

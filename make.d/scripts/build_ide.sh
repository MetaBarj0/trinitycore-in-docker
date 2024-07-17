build_arg_arg=

# TODO: simplify by refactor, platform local value
if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
  build_arg_arg='--build-arg PLATFORM_TAG='"${platform_tag}"
fi

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  build_arg_arg="$(cat << EOF
  ${build_arg_arg} \
  --build-arg USER=docker \
  --build-arg USER_HOME_DIR=/home/docker
EOF
)"
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  build_arg_arg="$(cat << EOF
  ${build_arg_arg} \
  --build-arg USER=root \
  --build-arg USER_HOME_DIR=/root
EOF
)"
fi

build_command="$(cat << EOF
docker compose -f docker.d/docker-compose.yml build ${build_arg_arg} ide 
EOF
)"

eval ${build_command}

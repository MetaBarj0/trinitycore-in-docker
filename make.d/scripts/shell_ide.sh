# TODO: simplify
# TODO: make this target faster with optimistic trys: shell not working, try
#       up, up not working, make build
if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  env_args="$(cat << EOF
  --env USER_GID=$(getent group docker | cut -d : -f 3) \
  --env USER_UID=$(id -u) \
  --env USER_HOME_DIR=/home/docker
EOF
  )"
fi

if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
  env_args="$(cat << EOF
  --env USER_GID=0 \
  --env USER_UID=0 \
  --env USER_HOME_DIR=/root
EOF
  )"
fi

cmd="$(cat << EOF
docker exec ${env_args} -it ${COMPOSE_PROJECT_NAME}_ide_container bash
EOF
)"

eval "${cmd}"

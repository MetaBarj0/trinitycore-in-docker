#TODO: move USER_HOME_DIR setup at build_servers_and_tools_builder step
if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  export USER_HOME_DIR=/home/docker
else
  export USER_HOME_DIR=/root
fi

docker compose up servers_and_tools_builder
docker compose down servers_and_tools_builder

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
  export USER_HOME_DIR=/home/docker
else
  export USER_HOME_DIR=/root
fi

docker compose up -d ide

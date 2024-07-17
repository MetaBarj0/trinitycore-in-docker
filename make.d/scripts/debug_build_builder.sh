export BUILDX_EXPERIMENTAL=1

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    USER=docker
    USER_GID=$(getent group docker | cut -d : -f 3)
    USER_HOME_DIR=/home/docker
    USER_UID=$(id -u)
fi

if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    USER=root
    USER_GID=0
    USER_HOME_DIR=/root
    USER_UID=0
fi

docker buildx debug build \
  --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
  --build-arg NAMESPACE=${NAMESPACE} \
  --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
  --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
  --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
  --build-arg USER=${USER} \
  --build-arg USER_GID=${USER_GID} \
  --build-arg USER_HOME_DIR=${USER_HOME_DIR} \
  --build-arg USER_UID=${USER_UID} \
  -f docker.d/builder/builder.Dockerfile \
  --ssh=default \
  -t ${NAMESPACE}.builder:${BUILDER_VERSION} \
  docker.d/builder

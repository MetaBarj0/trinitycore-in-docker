export BUILDX_EXPERIMENTAL=1

# TODO: remove duplication
if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
	docker buildx debug build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
    --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
    --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=docker \
    --build-arg USER_GID=$(getent group docker | cut -d : -f 3) \
    --build-arg USER_HOME_DIR=/home/docker \
    --build-arg USER_UID=$(id -u) \
    -f docker.d/builder/builder.Dockerfile \
    --ssh=default \
    docker.d/builder
else
	docker buildx build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg REPOSITORY_URI=${REPOSITORY_URI} \
    --build-arg REPOSITORY_REV=${REPOSITORY_REV} \
    --build-arg REPOSITORY_SHA=${REPOSITORY_SHA} \
    --build-arg USE_DOCKER_DESKTOP=${USE_DOCKER_DESKTOP} \
    --build-arg USER=root \
    --build-arg USER_GID=0 \
    --build-arg USER_HOME_DIR=/root \
    --build-arg USER_UID=0 \
    --invoke /bin/bash \
    -f docker.d/builder/builder.Dockerfile \
    --ssh=default \
    docker.d/builder
fi

# TODO: refactor using the special value for platform: 'local'
if ! [ -z "$TARGET_PLATFORM" ];then
  platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"

  docker build \
    --platform $TARGET_PLATFORM \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/common/debian_12_slim_upgraded.Dockerfile \
    -t "${NAMESPACE}".debian"${platform_tag}":12_slim_upgraded \
    docker.d/common
else
  docker build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/common/debian_12_slim_upgraded.Dockerfile \
    -t "${NAMESPACE}".debian:12_slim_upgraded \
    docker.d/common
fi


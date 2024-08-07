docker build \
  --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
  --build-arg NAMESPACE=${NAMESPACE} \
  -f docker.d/debian_12_slim_upgraded.Dockerfile \
  -t "${NAMESPACE}".debian:12_slim_upgraded \
  docker.d

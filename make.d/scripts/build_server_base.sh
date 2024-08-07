docker build \
  --build-arg COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME}" \
  --build-arg NAMESPACE="${NAMESPACE}" \
  --build-arg TRINITYCORE_USER_GID=${TRINITYCORE_USER_GID} \
  --build-arg TRINITYCORE_USER_UID=${TRINITYCORE_USER_UID} \
  -f docker.d/serverbase.Dockerfile \
  -t "${NAMESPACE}".serverbase:${BUILDERBASE_VERSION} \
  docker.d

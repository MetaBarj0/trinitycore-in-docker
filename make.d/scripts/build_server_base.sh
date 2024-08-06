main() {
  local target_platform=local

  if [ ! -z "$TARGET_PLATFORM" ] && [ 'local' != "${TARGET_PLATFORM}" ];then
    local platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
    target_platform="${TARGET_PLATFORM}"
  fi

  docker build \
    --platform "${target_platform}" \
    --build-arg COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME}" \
    --build-arg NAMESPACE="${NAMESPACE}" \
    --build-arg PLATFORM_TAG="${platform_tag}" \
    --build-arg TRINITYCORE_USER_GID=${TRINITYCORE_USER_GID} \
    --build-arg TRINITYCORE_USER_UID=${TRINITYCORE_USER_UID} \
    -f docker.d/serverbase.Dockerfile \
    -t "${NAMESPACE}".serverbase"${platform_tag}" \
    docker.d
}

main

main() {
  local platform_tag=''
  local target_platform=local

  if ! [ -z "$TARGET_PLATFORM" ];then
    platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
    target_platform="${TARGET_PLATFORM}"
  fi

  docker build \
    --platform "${target_platform}" \
    --build-arg COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME}" \
    --build-arg NAMESPACE="${NAMESPACE}" \
    --build-arg PLATFORM_TAG="${platform_tag}" \
    -f docker.d/serverbase.Dockerfile \
    -t "${NAMESPACE}".serverbase"${platform_tag}" \
    docker.d
}

main

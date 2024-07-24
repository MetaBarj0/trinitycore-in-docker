main() {
  local platform_tag=''
  local target_platform=local

  if ! [ -z "$TARGET_PLATFORM" ];then
    platform_tag=".$(echo $TARGET_PLATFORM | sed 's/\//./')"
    target_platform="${TARGET_PLATFORM}"
  fi

  docker build \
    --platform "${target_platform}" \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/debian_12_slim_upgraded.Dockerfile \
    -t "${NAMESPACE}".debian"${platform_tag}":12_slim_upgraded \
    docker.d
}

main

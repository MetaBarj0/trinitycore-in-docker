if [ "${remove_volumes}" = "true" ]; then
  docker compose -f docker.d/docker-compose.yml down --volumes
else
  docker compose -f docker.d/docker-compose.yml down
fi

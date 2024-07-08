if [ "${remove_volumes}" = "true" ]; then
  docker compose down --volumes
  docker compose down ide --volumes
else
  docker compose down
  docker compose down ide
fi

if [ "${remove_volumes}" = "true" ]; then
  docker compose down --volumes
else
  docker compose down
fi

if [ -z "$cmd" ]; then
  cat << EOF >&2
You must specify a command to execute on the worldserver
Example: make exec cmd='server info'
EOF

  exit 1
fi

# TODO: rename container in compose to prevent scaling
docker exec ${COMPOSE_PROJECT_NAME}-worldserver_remote_access-1 \
  sh -c "execute_console_command.sh '${cmd}'"

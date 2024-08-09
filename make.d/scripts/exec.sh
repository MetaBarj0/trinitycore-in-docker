if [ -z "$cmd" ]; then
  cat << EOF >&2
You must specify a command to execute on the worldserver
Example: make exec cmd='server info'
EOF

  exit 1
fi

docker exec ${COMPOSE_PROJECT_NAME}_worldserver_remote_access \
  sh -c "execute_console_command.sh '${cmd}'"

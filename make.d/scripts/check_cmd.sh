if [ -z "$cmd" ]; then
  cat << EOF >&2
You must specify a command to execute on the worldserver
Example: make exec cmd='server info'
EOF

  exit 1
fi

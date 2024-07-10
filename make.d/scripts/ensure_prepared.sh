check_for_configuration_file() {
  local file_path="$1"

  if [ ! -f "${file_path}" ]; then
    echo "${file_path} missing." >&2

    return 1
  fi
}

print_user_guidance() {
  cat << EOF >&2

Problem:
--------

One or more server configuration files are missing and you attempted to build
trinitycore servers without them. If you would have continued, the build would
have miserably failed and you would have been dispaired by the resulting
cryptic error message.

Solution:
---------

Issue the following command:

- make prepare

And follow instruction. Then you could just build the whole thing with:

- make build
EOF

  return 1
}

main() {
  check_for_configuration_file "${AUTHSERVER_CONF_PATH}" \
  && check_for_configuration_file "${WORLDSERVER_CONF_PATH}" \
  || print_user_guidance
}

main

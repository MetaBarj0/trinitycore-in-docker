check_for_configuration_file() {
  local file_path="$1"

  if [ ! -f "${file_path}" ]; then
    echo "${file_path} missing." >&2

    return 1
  fi
}

print_user_guidance_for_configuration_files() {
  cat << EOF >&2

Problem:
--------

One or more server configuration files are missing and you attempted to build
trinitycore servers without them. If you would have continued, the build would
have miserably failed and you would have been dispaired by the resulting
cryptic error message.

Solution:
---------

Issue one of these following commands:

- make init (autopilot initialization, guided)
- make prepare (manual initialization)

And follow instructions. Then you could just build the whole thing with:

- make build
EOF

  return 1
}

check_configuration_files() {
  check_for_configuration_file "${AUTHSERVER_CONF_PATH}" \
  && check_for_configuration_file "${WORLDSERVER_CONF_PATH}" \
  || print_user_guidance_for_configuration_files
}

check_use_docker_desktop_variable() {
  [ ${USE_DOCKER_DESKTOP} -ne 0 ] \
  && [ ${USE_DOCKER_DESKTOP} -ne 1 ]
}

# TODO: refactor problem/solution section construction into a function
print_user_guidance_for_use_docker_desktop() {
  cat << EOF >&2

Problem:
--------

The USE_DOCKER_DESKTOP variable contains an out-of-range value or does not
contain a value at all.

Solution:
---------

Edit the Makefile.env file and set the USE_DOCKER_DESKTOP variable value
according to instructions above the variable definition.
You could also issue the \`make init\` command to set only this variable to a
correct value and do not touch any other variable.
EOF

  return 1
}

check_use_docker_desktop() {
  check_use_docker_desktop_variable \
  || print_user_guidance_for_use_docker_desktop
}

check_client_path_variable() {
  [ ! -z "${CLIENT_PATH}" ]
}

print_user_guidance_for_client_path() {
  cat << EOF >&2
Problem:
--------

Missing value for the CLIENT_PATH variable. The build system cannot find the
World of Warcraft client installation directory. It is necessary to generate
all client data the server need to operate.

Solution:
---------

Edit the Makefile.env file, look for the CLIENT_PATH variable and set a correct
value here that is, the absolute path of the World of Warcraft client version
3.3.5a build 12340 directory.
You can also set the CLIENT_PATH variable with the \`make init\` command.
EOF

  return 1
}

check_client_path() {
  check_client_path_variable \
  || print_user_guidance_for_client_path
}

check_admin_account_name(){
  [ ! -z "${ADMIN_ACCOUNT_NAME}" ]
}

check_admin_account_password() {
  [ ! -z "${ADMIN_ACCOUNT_PASSWORD}" ]
}

print_user_guidance_for_admin_account() {
  cat << EOF >&2
Problem:
--------

Missing configuration for the administrator account used for remote access.
Missing values for either ADMIN_ACCOUNT_NAME or ADMIN_ACCOUNT_PASSWORD variable
in Makefile.env file.

Solution:
---------

Edit the Makefile.env file, look for ADMIN_ACCOUNT_NAME variable and set an
account name. Follow instructions in the comment above.
Edit the Makefile.env file, look for ADMIN_ACCOUNT_PASSWORD variable and set an
account password. Follow instructions in the comment above.
You can also set these variables by issuing the \`make init\` command and set
only ADMIN_ACCOUNT_NAME and ADMIN_ACCOUNT_PASSWORD variables.
EOF

 return 1
}

check_admin_account() {
  check_admin_account_name \
  && check_admin_account_password \
  || print_user_guidance_for_admin_account
}

check_realmlist_address() {
  [ ! -z "${REALMLIST_ADDRESS}" ]
}

print_user_guidance_for_realmlist_address() {
  cat << EOF >&2
Problem:
--------

Missing value for the REALMLIST_ADDRESS variable. Without this you could not
test or play with the built server.

Solution:
---------

Edit the Makefile.env file, find the REALMLIST_ADDRESS variable with a valid
value. Follow comment above the variable.
You could also issue the \`make init\` command to set this variable only.
EOF

  return 1
}

check_realm_address() {
  check_realmlist_address \
  || print_user_guidance_for_realmlist_address
}

main() {
  check_configuration_files \
  && check_use_docker_desktop \
  && check_client_path \
  && check_admin_account \
  && check_realm_address
}

main

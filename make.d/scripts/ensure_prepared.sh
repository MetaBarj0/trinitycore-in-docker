# TODO: introduce color
ensure_server_configuration_file_exists() {
  local file_path="$1"

  if [ ! -f "${file_path}" ]; then
    echo "${file_path} missing." >&2

    return 1
  fi
}

print_problem_solution_guildance() {
  local problem="$1"
  local solution="$2"

  cat << EOF >&2

Problem:
--------

${problem}

Solution:
---------

${solution}
EOF

  return 1
}

print_user_guidance_for_configuration_files() {
  print_problem_solution_guildance \
"One or more server configuration files are missing and you attempted to build
trinitycore servers without them. If you would have continued, the build would
have miserably failed and you would have been dispaired by the resulting
cryptic error message." \
"Issue one of these following commands:

- make init (autopilot initialization, guided)
- make prepare (manual initialization)

And follow instructions. Then you could just build the whole thing with:

- make build"
}

ensure_servers_configuration_files_exist() {
  ensure_server_configuration_file_exists "${AUTHSERVER_CONF_PATH}" \
  && ensure_server_configuration_file_exists "${WORLDSERVER_CONF_PATH}" \
  || print_user_guidance_for_configuration_files
}

check_use_docker_desktop_variable() {
  [ ${USE_DOCKER_DESKTOP} -ne 0 ] \
  || [ ${USE_DOCKER_DESKTOP} -ne 1 ]
}

print_user_guidance_for_use_docker_desktop() {
  print_problem_solution_guildance \
"The USE_DOCKER_DESKTOP variable contains an out-of-range value or does not
contain a value at all." \
"Edit the Makefile.env file and set the USE_DOCKER_DESKTOP variable value
according to instructions above the variable definition.
You could also issue the \`make init\` command to set only this variable to a
correct value and do not touch any other variable."
}

check_use_docker_desktop() {
  check_use_docker_desktop_variable \
  || print_user_guidance_for_use_docker_desktop
}

check_client_path_variable() {
  [ ! -z "${CLIENT_PATH}" ] \
  && [ -f "${CLIENT_PATH}/Wow.exe" ]
}

print_user_guidance_for_client_path() {
  print_problem_solution_guildance \
"Invalid value for the CLIENT_PATH variable. The build system cannot find the
World of Warcraft client installation directory. It is necessary to generate
all client data the server need to operate." \
"Edit the Makefile.env file, look for the CLIENT_PATH variable and set a correct
value here that is, the absolute path of the World of Warcraft client version
3.3.5a build 12340 directory.
You can also set the CLIENT_PATH variable with the \`make init\` command."
}

check_client_path() {
  check_client_path_variable \
  || print_user_guidance_for_client_path
}

check_worldserver_conf_path() {
  :
}

check_authserver_conf_path() {
  :
}

check_admin_account_name(){
  [ ! -z "${ADMIN_ACCOUNT_NAME}" ]
}

check_admin_account_password() {
  [ ! -z "${ADMIN_ACCOUNT_PASSWORD}" ]
}

print_user_guidance_for_admin_account() {
  print_problem_solution_guildance \
"Missing configuration for the administrator account used for remote access.
Missing values for either ADMIN_ACCOUNT_NAME or ADMIN_ACCOUNT_PASSWORD variable
in Makefile.env file." \
"Edit the Makefile.env file, look for ADMIN_ACCOUNT_NAME variable and set an
account name. Follow instructions in the comment above.
Edit the Makefile.env file, look for ADMIN_ACCOUNT_PASSWORD variable and set an
account password. Follow instructions in the comment above.
You can also set these variables by issuing the \`make init\` command and set
only ADMIN_ACCOUNT_NAME and ADMIN_ACCOUNT_PASSWORD variables."
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
  print_problem_solution_guildance \
"Missing value for the REALMLIST_ADDRESS variable. Without this you could not
test or play with the built server." \
"Edit the Makefile.env file, find the REALMLIST_ADDRESS variable with a valid
value. Follow comment above the variable.
You could also issue the \`make init\` command to set this variable only."
}

check_realm_address() {
  check_realmlist_address \
  || print_user_guidance_for_realmlist_address
}

check_makefile_env_variables() {
  check_use_docker_desktop \
  && check_client_path \
  && check_worldserver_conf_path \
  && check_authserver_conf_path \
  && check_admin_account \
  && check_realm_address
}

main() {
  ensure_servers_configuration_files_exist \
  && check_makefile_env_variables
}

main

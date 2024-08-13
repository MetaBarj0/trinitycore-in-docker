. make.d/scripts/color.sh

ensure_server_configuration_file_exists() {
  local file_path="$1"

  if [ ! -f "${file_path}" ]; then
    echo "${file_path} missing." >&2

    return 1
  fi
}

print_problem_solution_guidance() {
  local problem="$1"
  local solution="$2"

  set_print_red
  cat << EOF >&2
Problem:
--------

${problem}
EOF

  set_print_blue
  cat << EOF >&2
Solution:
---------

${solution}
EOF

  reset_print_color

  return 1
}

print_user_guidance_for_configuration_files() {
  print_problem_solution_guidance \
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
  [ ${USE_DOCKER_DESKTOP} -eq 0 ] \
  || [ ${USE_DOCKER_DESKTOP} -eq 1 ]
}

print_user_guidance_for_use_docker_desktop() {
  print_problem_solution_guidance \
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
  [ -n "${CLIENT_PATH}" ] \
  && [ -f "${CLIENT_PATH}/Wow.exe" ]
}

print_user_guidance_for_client_path() {
  print_problem_solution_guidance \
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

str_compare_with() {
  local fragment="$1"

  while read input; do
    [ "${input}" = "${fragment}" ] \
    && return 0 \
    || return 1
  done
}

ensure_path_ends_with() {
  local uri="$1"
  local fragment="$2"

  echo "${uri}" \
  | rev \
  | sed -E 's%(^[^/]+)/%\1%' \
  | rev \
  | str_compare_with "${fragment}"
}

print_user_guidance_for_worldserver_conf_path() {
  print_problem_solution_guidance \
"Missing or invalid value for the WORLDSERVER_CONF_PATH variable. The build
will fail without a valid value.
Make sure you specify either an absolute or a relative file path ending with
'worldserver.conf'" \
"Edit the Makefile.env file, look for the WORLDSERVER_CONF_PATH variable and
set a correct value here.
You can also set the WORLDSERVER_CONF_PATH variable with the \`make init\`
command."
}

check_worldserver_conf_path() {
  [ -n "${WORLDSERVER_CONF_PATH}" ] \
  && ensure_path_ends_with "${WORLDSERVER_CONF_PATH}" 'worldserver.conf' \
  || print_user_guidance_for_worldserver_conf_path
}

print_user_guidance_for_authserver_conf_path() {
  print_problem_solution_guidance \
"Missing or invalid value for the AUTHSERVER_CONF_PATH variable. The build
will fail without a valid value.
Make sure you specify either an absolute or a relative file path ending with
'authserver.conf'" \
"Edit the Makefile.env file, look for the AUTHSERVER_CONF_PATH variable and
set a correct value here.
You can also set the AUTHSERVER_CONF_PATH variable with the \`make init\`
command."
}

check_authserver_conf_path() {
  [ -n "${AUTHSERVER_CONF_PATH}" ] \
  && ensure_path_ends_with "${AUTHSERVER_CONF_PATH}" 'authserver.conf' \
  || print_user_guidance_for_authserver_conf_path
}

check_realmlist_address() {
  [ -n "${REALMLIST_ADDRESS}" ]
}

print_user_guidance_for_realmlist_address() {
  print_problem_solution_guidance \
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
  && check_realm_address
}

output_makefile_maintainer_solution() {
  cat << EOF
initialize this variable either with:
- make init maintainer_mode=1 and follow the guide
- make prepare and manually edit the Makefile.maintainer.env
  file.
EOF
}

print_user_guidance_for_tdb_uri() {
  print_problem_solution_guidance \
"Missing value for the TDB_FULL_URI variable.
The build will succeed but the first run of server will fail to
initialize and update all needed databases" \
"$(output_makefile_maintainer_solution)"
}

check_tdb_full_uri() {
  [ -n "${TDB_FULL_URI}" ] \
  || print_user_guidance_for_tdb_uri
}

print_user_guidance_for_compose_project_name() {
  print_problem_solution_guidance \
"Missing value for the COMPOSE_PROJECT_NAME variable.
The build will fail as produced docker image names rely on this
variable value." \
"$(output_makefile_maintainer_solution)"
}

check_compose_project_name() {
  [ -n "${COMPOSE_PROJECT_NAME}" ] \
  || print_user_guidance_for_compose_project_name
}

print_user_guidance_for_namespace() {
  print_problem_solution_guidance \
"Missing value for the NAMESPACE variable.
The build will fail as produced docker image names rely on this
variable value." \
"$(output_makefile_maintainer_solution)"
}

check_namespace() {
  [ -n "${NAMESPACE}" ] \
  || print_user_guidance_for_namespace
}

print_user_guidance_for_repository_uri() {
  print_problem_solution_guidance \
"Missing value for the REPOSITORY_URI variable.
The build will fail because no TrinityCore repository will be
cloned." \
"$(output_makefile_maintainer_solution)"
}

check_repository_uri() {
  [ -n "${REPOSITORY_URI}" ] \
  || print_user_guidance_for_repository_uri
}

print_user_guidance_for_raw_repository_uri() {
  print_problem_solution_guidance \
"Missing value for the RAW_REPOSITORY_URI variable.
The build will fail because the system won't be able to create
worldserver.conf and authserver.conf file for servers to run." \
"$(output_makefile_maintainer_solution)"
}

check_raw_repository_uri() {
  [ -n "${RAW_REPOSITORY_URI}" ] \
  || print_user_guidance_for_raw_repository_uri
}

print_user_guidance_for_repository_rev() {
  print_problem_solution_guidance \
"Missing value for the REPOSITORY_REV variable.
The build will fail because a specific revision (tag, branch)
must be set for the TrinityCore repository clone to proceed." \
"$(output_makefile_maintainer_solution)"
}

check_repository_rev() {
  [ -n "${REPOSITORY_REV}" ] \
  || print_user_guidance_for_repository_rev
}

print_user_guidance_for_use_cached_client_data() {
  print_problem_solution_guidance \
"Missing or invalid value for the USE_CACHED_CLIENT_DATA
variable. This value must be set with either 0 or 1." \
"$(output_makefile_maintainer_solution)"
}

check_use_cached_client_data() {
  [ ${USE_CACHED_CLIENT_DATA} -eq 0 ] \
  || [ ${USE_CACHED_CLIENT_DATA} -eq 1 ] \
  || print_user_guidance_for_use_cached_client_data
}

print_user_guidance_for_databases_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the DATABASES_VERSION variable.
The build of the databases service will fail because it relies on this variable
value." \
"$(output_makefile_maintainer_solution)"
}

check_databases_version() {
  [ -n "${DATABASES_VERSION}" ] \
  || print_user_guidance_for_databases_version
}

print_user_guidance_for_builderbase_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the BUILDERBASE_VERSION variable.
The build of the builderbase image will fail because it relies on this variable
value." \
"$(output_makefile_maintainer_solution)"
}

check_builderbase_version() {
  [ -n "${BUILDERBASE_VERSION}" ] \
  || print_user_guidance_for_builderbase_version
}

print_user_guidance_for_serverbase_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the check_serverbase_version variable.
The build of the serverbase image will fail because it relies on this variable
value." \
"$(output_makefile_maintainer_solution)"
}

check_serverbase_version() {
  [ -n "${SERVERBASE_VERSION}" ] \
  || print_user_guidance_for_serverbase_version
}

print_user_guidance_for_builder_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the BUILDER_VERSION variable.
The build of the builder image will fail because it relies on this variable
value." \
"$(output_makefile_maintainer_solution)"
}

check_builder_version() {
  [ -n "${BUILDER_VERSION}" ] \
  || print_user_guidance_for_builder_version
}

print_user_guidance_for_ide_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the IDE_VERSION variable.
The build of the ide service will fail because it relies on this variable
value." \
"$(output_makefile_maintainer_solution)"
}

check_ide_version() {
  [ -n "${IDE_VERSION}" ] \
  || print_user_guidance_for_ide_version
}

print_user_guidance_for_worldserver_remote_access_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the WORLDSERVER_REMOTE_ACCESS_VERSION variable.
The build of the worldserver_remote_access service will fail because it relies
on this variable value." \
"$(output_makefile_maintainer_solution)"
}

check_worldserver_remote_access_version() {
  [ -n "${WORLDSERVER_REMOTE_ACCESS_VERSION}" ] \
  || print_user_guidance_for_worldserver_remote_access_version
}

print_user_guidance_for_gameservers_version() {
  print_problem_solution_guidance \
"Missing or invalid value for the GAMESERVERS_VERSION variable.
The build of the worldserver and authserver services will fail because it
relies on this variable value." \
"$(output_makefile_maintainer_solution)"
}

check_gameservers_version() {
  [ -n "${GAMESERVERS_VERSION}" ] \
  || print_user_guidance_for_gameservers_version
}

check_versions() {
  check_databases_version \
  && check_builderbase_version \
  && check_serverbase_version \
  && check_builder_version \
  && check_ide_version \
  && check_worldserver_remote_access_version \
  && check_gameservers_version
}

print_user_guidance_for_trinitycore_user_gid() {
  print_problem_solution_guidance \
"Missing or invalid value for the TRINITYCORE_USER_GID variable. This value
must be set with a value above 1000" \
"$(output_makefile_maintainer_solution)"
}

check_trinitycore_user_gid() {
  [ ${TRINITYCORE_USER_GID} -gt 1000 ] \
  || print_user_guidance_for_trinitycore_user_gid
}

print_user_guidance_for_trinitycore_user_uid() {
  print_problem_solution_guidance \
"Missing or invalid value for the TRINITYCORE_USER_UID variable. This value
must be set with a value above 1000" \
"$(output_makefile_maintainer_solution)"
}

check_trinitycore_user_uid() {
  [ ${TRINITYCORE_USER_UID} -gt 1000 ] \
  || print_user_guidance_for_trinitycore_user_uid
}

print_user_guidance_for_ssh_public_key_file_path() {
  print_problem_solution_guidance \
"Missing value for the SSH_PUBLIC_KEY_FILE_PATH variable. The build of the
ide service will fail because this key is required to setup the development
environment." \
"$(output_makefile_maintainer_solution)"
}

check_ssh_public_key_path() {
  [ -n "${SSH_PUBLIC_KEY_FILE_PATH}" ] \
  || print_user_guidance_for_ssh_public_key_file_path
}

print_user_guidance_for_ssh_secret_key_file_path() {
  print_problem_solution_guidance \
"Missing value for the SSH_SECRET_KEY_FILE_PATH variable. The build of the
ide service will fail because this key is required to setup the development
environment." \
"$(output_makefile_maintainer_solution)"
}

check_ssh_secret_key_path() {
  [ -n "${SSH_SECRET_KEY_FILE_PATH}" ] \
  || print_user_guidance_for_ssh_secret_key_file_path
}

print_user_guidance_for_neovim_rev() {
  print_problem_solution_guidance \
"Missing value for the NEOVIM_REV variable. The build of the ide service will
fail because neovim is the main code editor of this environment and cannot be
built without this variable value." \
"$(output_makefile_maintainer_solution)"
}

check_neovim_rev() {
  [ -n "${NEOVIM_REV}" ] \
  || print_user_guidance_for_neovim_rev
}

print_user_guidance_for_nodejs_rev() {
  print_problem_solution_guidance \
"Missing value for the NODEJS_VER variable. The build of the
ide service will fail as nodejs is a necessary dependency." \
"$(output_makefile_maintainer_solution)"
}

check_nodejs_rev() {
  [ -n "${NODEJS_VER}" ] \
  || print_user_guidance_for_nodejs_rev
}

print_user_guidance_for_git_user_name() {
  print_problem_solution_guidance \
"Missing value for the GIT_USER_NAME variable. The git user name is essential
to identify yourself in commits you could made to contribute to the wonderful
TrinityCore project." \
"$(output_makefile_maintainer_solution)"
}

check_git_user_name() {
  [ -n "${GIT_USER_NAME}" ] \
  || print_user_guidance_for_git_user_name
}

print_user_guidance_for_git_user_email() {
  print_problem_solution_guidance \
"Missing value for the GIT_USER_EMAIL variable. The git user email is
essential to identify yourself in commits you could made to contribute to the
wonderful TrinityCore project." \
"$(output_makefile_maintainer_solution)"
}

check_git_user_email() {
  [ -n "${GIT_USER_EMAIL}" ] \
  || print_user_guidance_for_git_user_email
}

print_user_guidance_for_repository_target_directory() {
  print_problem_solution_guidance \
"Missing value for the TRINITYCORE_REPOSITORY_TARGET_DIRECTORY variable. This
variable value is essential for some scripts in the ide service to run
properly." \
"$(output_makefile_maintainer_solution)"
}

check_trinitycore_repository_target_directory() {
  [ -n "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" ] \
  || print_user_guidance_for_repository_target_directory
}

print_user_guidance_for_trinitycore_install_directory() {
  print_problem_solution_guidance \
"Missing value for the TRINITYCORE_INSTALL_DIRECTORY variable. This variable
value is essential for some scripts in the ide service to run properly." \
"$(output_makefile_maintainer_solution)"
}

check_trinitycore_install_directory() {
  [ -n "${TRINITYCORE_INSTALL_DIRECTORY}" ] \
  || print_user_guidance_for_trinitycore_install_directory
}

print_user_guidance_for_shell_user_name() {
  print_problem_solution_guidance \
"Missing value for the SHELL_USER_NAME variable. This variable value is
essential to allow you to login into the ide service container." \
"$(output_makefile_maintainer_solution)"
}

check_shell_user_name() {
  [ -n "${SHELL_USER_NAME}" ] \
  || print_user_guidance_for_shell_user_name
}

print_user_guidance_for_shell_user_home_dir() {
  print_problem_solution_guidance \
"Missing value for the SHELL_USER_HOME_DIR variable. This variable value is
essential to setup the home directory of your user into the ide service
container." \
"$(output_makefile_maintainer_solution)"
}

check_shell_user_home_dir() {
  [ -n "${SHELL_USER_HOME_DIR}" ] \
  || print_user_guidance_for_shell_user_home_dir
}

print_user_guidance_for_debug_authserver_port() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_AUTHSERVER_PORT variable. This variable value is
essential to setup the debug authserver port and make it runnable. Be sure to
setup a value that is greater than 3724 and lesser than 65535 (it is a port)" \
"$(output_makefile_maintainer_solution)"
}

check_debug_authserver_port() {
  [ ${DEBUG_AUTHSERVER_PORT} -gt 3724 ] \
  && [ ${DEBUG_AUTHSERVER_PORT} -lt 65535 ] \
  || print_user_guidance_for_debug_authserver_port
}

print_user_guidance_for_debug_worldserver_port() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_WORLDSERVER_PORT variable. This
variable value is essential to setup the debug authserver port and make it
runnable. Be sure to setup a value that is greater than 8085 and lesser than
65535 (it is a port)" \
"$(output_makefile_maintainer_solution)"
}

check_debug_worldserver_port() {
  [ ${DEBUG_WORLDSERVER_PORT} -gt 8085 ] \
  && [ ${DEBUG_WORLDSERVER_PORT} -lt 65535 ] \
  || print_user_guidance_for_debug_worldserver_port
}

check_debug_servers_ports() {
  check_debug_authserver_port \
  && check_debug_worldserver_port
}

print_user_guidance_for_debug_auth_database_name() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_AUTH_DATABASE_NAME variable. This
variable value is essential to setup the debug version of the auth database.
You must specify a value here. The name 'auth' is forbidden." \
"$(output_makefile_maintainer_solution)"
}

check_debug_auth_database_name() {
  [ -n "${DEBUG_AUTH_DATABASE_NAME}" ] \
  && [ "${DEBUG_AUTH_DATABASE_NAME}" != 'auth' ] \
  || print_user_guidance_for_debug_auth_database_name
}

print_user_guidance_for_debug_characters_database_name() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_CHARACTERS_DATABASE_NAME variable. This
variable value is essential to setup the debug version of the characters
database. You must specify a value here. The name 'characters' is forbidden." \
"$(output_makefile_maintainer_solution)"
}

check_debug_characters_database_name() {
  [ -n "${DEBUG_CHARACTERS_DATABASE_NAME}" ] \
  && [ "${DEBUG_CHARACTERS_DATABASE_NAME}" != 'characters' ] \
  || print_user_guidance_for_debug_characters_database_name
}

print_user_guidance_for_debug_world_database_name() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_WORLD_DATABASE_NAME variable. This
variable value is essential to setup the debug version of the world database.
You must specify a value here. The name 'world' is forbidden." \
"$(output_makefile_maintainer_solution)"
}

check_debug_world_database_name() {
  [ -n "${DEBUG_WORLD_DATABASE_NAME}" ] \
  && [ "${DEBUG_WORLD_DATABASE_NAME}" != 'world' ] \
  || print_user_guidance_for_debug_world_database_name
}

check_debug_database_names() {
  check_debug_auth_database_name \
  && check_debug_characters_database_name \
  && check_debug_world_database_name
}

print_user_guidance_for_debug_realm_id() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_REALM_ID variable. This variable value
is essential to setup the debug realm identifier. You must specify a value
here. Any value greater than 1 will do." \
"$(output_makefile_maintainer_solution)"
}

check_debug_realm_id() {
  [ ${DEBUG_REALM_ID} -gt 1 ] \
  || print_user_guidance_for_debug_realm_id
}

print_user_guidance_for_debug_realmlist_address() {
  print_problem_solution_guidance \
"Missing or invalid value for the DEBUG_REALMLIST_ADDRESS variable. This variable value
is essential to make your debug realm reachable on your network." \
"$(output_makefile_maintainer_solution)"
}

check_debug_realmlist_address() {
  [ -n "${DEBUG_REALMLIST_ADDRESS}" ] \
  || print_user_guidance_for_debug_realmlist_address
}

check_makefile_maintainer_env_variables() {
  check_tdb_full_uri \
  && check_compose_project_name \
  && check_namespace \
  && check_repository_uri \
  && check_raw_repository_uri \
  && check_repository_rev \
  && check_use_cached_client_data \
  && check_versions \
  && check_trinitycore_user_gid \
  && check_trinitycore_user_uid \
  && check_ssh_public_key_path \
  && check_ssh_secret_key_path \
  && check_neovim_rev \
  && check_nodejs_rev \
  && check_git_user_name \
  && check_git_user_email \
  && check_trinitycore_repository_target_directory \
  && check_trinitycore_install_directory \
  && check_shell_user_name \
  && check_shell_user_home_dir \
  && check_debug_servers_ports \
  && check_debug_database_names \
  && check_debug_realm_id \
  && check_debug_realmlist_address
}

main() {
  check_makefile_env_variables \
  && check_makefile_maintainer_env_variables \
  && ensure_servers_configuration_files_exist
}

main

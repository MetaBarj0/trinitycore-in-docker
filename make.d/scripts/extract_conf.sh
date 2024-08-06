is_authserver_image_exists() {
  local image_name="${NAMESPACE}.authserver:${AUTHSERVER_VERSION}"
  local id=$(docker image ls -q ${image_name})

  [ ! -z "$id" ]
}

is_authserver_conf_file_already_backed_up() {
  [ -f "${AUTHSERVER_CONF_PATH}.old" ]
}

backup_authserver_conf_file() {
  cp -f "${AUTHSERVER_CONF_PATH}" "${AUTHSERVER_CONF_PATH}.old"
}

backup_authserver_conf_file_if_needed() {
  [ ! -f "${AUTHSERVER_CONF_PATH}" ] && return 0

  is_authserver_conf_file_already_backed_up \
  || backup_authserver_conf_file
}

is_makefile_env_file_already_backed_up() {
  [ -f 'Makefile.env.old' ]
}

backup_makefile_env() {
  cp -f "Makefile.env" "Makefile.env.old"
}

backup_makefile_env_if_needed() {
  [ ! -f "Makefile.env" ] && return 0

  is_makefile_env_file_already_backed_up \
  || backup_makefile_env
}

is_makefile_maintainer_env_file_already_backed_up() {
  [ -f 'Makefile.maintainer.env.old' ]
}

backup_makefile_maintainer_env() {
  cp -f "Makefile.maintainer.env" "Makefile.maintainer.env.old"
}

backup_makefile_maintainer_env_if_needed() {
  [ ! -f "Makefile.maintainer.env" ] && return 0

  is_makefile_maintainer_env_file_already_backed_up \
  || backup_makefile_maintainer_env
}

backup_env_files_if_needed() {
  backup_makefile_env_if_needed \
  && backup_makefile_maintainer_env_if_needed
}

extract_conf_files_from_authserver() {
  local container_id=$(docker run --rm -it -d ${NAMESPACE}.authserver:${AUTHSERVER_VERSION})

  docker exec ${container_id} tar x -f configuration_files.tar

  docker cp ${container_id}:/home/trinitycore/authserver.conf "${AUTHSERVER_CONF_PATH}" > /dev/null
  docker cp ${container_id}:/home/trinitycore/Makefile.env . > /dev/null
  docker cp ${container_id}:/home/trinitycore/Makefile.maintainer.env . > /dev/null

  docker kill ${container_id} > /dev/null
}

extract_authserver_conf() {
  is_authserver_image_exists \
  && backup_authserver_conf_file_if_needed \
  && backup_env_files_if_needed \
  && extract_conf_files_from_authserver
}

is_worldserver_image_exists() {
  local image_name="${NAMESPACE}.worldserver:${WORLDSERVER_VERSION}"
  local id=$(docker image ls -q ${image_name})

  [ ! -z "$id" ]
}

is_worldserver_conf_file_already_backed_up() {
  [ -f "${WORLDSERVER_CONF_PATH}.old" ]
}

backup_worldserver_conf_file() {
  cp -f "${WORLDSERVER_CONF_PATH}" "${WORLDSERVER_CONF_PATH}.old"
}

backup_worldserver_conf_file_if_needed() {
  [ ! -f "${WORLDSERVER_CONF_PATH}" ] && return 0

  is_worldserver_conf_file_already_backed_up \
  || backup_worldserver_conf_file
}

extract_conf_files_from_worldserver() {
  local container_id=$(docker run --rm -it -d ${NAMESPACE}.worldserver:${WORLDSERVER_VERSION})

  docker exec ${container_id} tar x -f configuration_files.tar

  docker cp ${container_id}:/home/trinitycore/worldserver.conf "${WORLDSERVER_CONF_PATH}" > /dev/null
  docker cp ${container_id}:/home/trinitycore/Makefile.env . > /dev/null
  docker cp ${container_id}:/home/trinitycore/Makefile.maintainer.env . > /dev/null

  docker kill ${container_id} > /dev/null
}

extract_worldserver_conf() {
  is_worldserver_image_exists \
  && backup_worldserver_conf_file_if_needed \
  && backup_env_files_if_needed \
  && extract_conf_files_from_worldserver
}

extract_game_servers_conf() {
  extract_authserver_conf \
  && extract_worldserver_conf
}

report_total_success() {
  cat << EOF
Info: configuration files have been extracted successfully.
-----
EOF
}

report_game_servers_conf_extraction_failure() {
  cat << EOF >&2

Warning: some game server configuration files couldn't be extracted. Make sure
-------- both the worldserver and the authserver docker images have been built.
Issue the following command to resolve this issue:
\`make build\`

EOF
}

is_databases_image_exists() {
  local image_name="${NAMESPACE}.databases:${DATABASES_VERSION}"
  local id=$(docker image ls -q ${image_name})

  [ ! -z "$id" ]
}

extract_makefiles_from_container() {
  local container_name="$1"
  local container_version="$2"

  local container_id=$(docker run --rm -it -d ${NAMESPACE}.${container_name}:${container_version})

  local user_home_dir=$(docker exec ${container_id} env \
                        | grep USER_HOME_DIR \
                        | sed 's/USER_HOME_DIR=//')

  docker exec ${container_id} tar x -f configuration_files.tar

  docker cp ${container_id}:${user_home_dir}/Makefile.env . > /dev/null
  docker cp ${container_id}:${user_home_dir}/Makefile.maintainer.env . > /dev/null

  docker kill ${container_id} > /dev/null
}

extract_databases_conf() {
  is_databases_image_exists \
  && backup_env_files_if_needed \
  && extract_makefiles_from_container 'databases' "${DATABASES_VERSION}"
}

is_worldserver_remote_access_image_exists() {
  local image_name="${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION}"
  local id=$(docker image ls -q ${image_name})

  [ ! -z "$id" ]
}

extract_worldserver_remote_access_conf() {
  is_worldserver_remote_access_image_exists \
  && backup_env_files_if_needed \
  && extract_makefiles_from_container 'worldserver_remote_access' "${WORLDSERVER_REMOTE_ACCESS_VERSION}"
}

extract_auxiliary_servers_conf() {
  extract_databases_conf \
  || extract_worldserver_remote_access_conf
}

report_partial_success() {
  cat << EOF >&2
Warning: Makefile.env and Makefile.maintainer.env could have been extracted.
-------- However, game server configuration extraction failed. Refer to the
previous warning message to solve this issue.

EOF
}

report_total_failure() {
  cat << EOF >&2
Fatal: Could not extract any configuration file. Make sure docker image have
------ been built before invoke the \`extract_config\` make target. Issue the
following command to solve your issue:
\`make build\`.
EOF
}

main() {
  extract_game_servers_conf \
  && report_total_success \
  || (
       report_game_servers_conf_extraction_failure \
       && extract_auxiliary_servers_conf \
       && report_partial_success \
       || report_total_failure
     )
}

main

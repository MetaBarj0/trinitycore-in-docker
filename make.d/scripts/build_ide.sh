. make.d/scripts/fetch_servers_configuration_files_in.sh

patch_authserver_configuration() {
  cd docker.d/ide > /dev/null

  patch authserver.conf << EOF
157c157
< SourceDirectory  = ""
---
> SourceDirectory  = "/home/trinitycore/TrinityCore"
207c207
< LoginDatabaseInfo = "127.0.0.1;3306;trinity;trinity;auth"
---
> LoginDatabaseInfo = "databases;3306;trinity;trinity;auth"
258c258
< Updates.EnableDatabases = 0
---
> Updates.EnableDatabases = 1
EOF

  cd - > /dev/null
}

patch_worldserver_configuration() {
  cd docker.d/ide > /dev/null

  patch worldserver.conf << EOF
76c76
< DataDir = "."
---
> DataDir = "/home/trinitycore/trinitycore/data"
110,112c110,112
< LoginDatabaseInfo     = "127.0.0.1;3306;trinity;trinity;auth"
< WorldDatabaseInfo     = "127.0.0.1;3306;trinity;trinity;world"
< CharacterDatabaseInfo = "127.0.0.1;3306;trinity;trinity;characters"
---
> LoginDatabaseInfo     = "databases;3306;trinity;trinity;auth"
> WorldDatabaseInfo     = "databases;3306;trinity;trinity;world"
> CharacterDatabaseInfo = "databases;3306;trinity;trinity;characters"
202c202
< SourceDirectory  = ""
---
> SourceDirectory  = "/home/trinitycore/TrinityCore"
3012c3012
< Console.Enable = 1
---
> Console.Enable = 0
3049c3049
< SOAP.Enabled = 0
---
> SOAP.Enabled = 1
3056c3056
< SOAP.IP = "127.0.0.1"
---
> SOAP.IP = "0.0.0.0"
EOF

  cd - > /dev/null
}

patch_configuration_file_in_build_context() {
  patch_authserver_configuration \
  && patch_worldserver_configuration
}

build_image() {
  if [ $USE_DOCKER_DESKTOP -eq 0 ]; then
    local user=${SHELL_USER_NAME}
    local user_home_dir=${SHELL_USER_HOME_DIR}
  fi

  if [ $USE_DOCKER_DESKTOP -eq 1 ]; then
    local user=root
    local user_home_dir=/root
  fi

  docker build \
    --build-arg BUILDERBASE_VERSION="${BUILDERBASE_VERSION}" \
    --build-arg CLIENT_PATH="${CLIENT_PATH}" \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NEOVIM_REV=${NEOVIM_REV} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg NODEJS_VER=${NODEJS_VER} \
    --build-arg USER=${user} \
    --build-arg USER_HOME_DIR=${user_home_dir} \
    -f docker.d/ide/ide.Dockerfile \
    -t ${NAMESPACE}.ide:${IDE_VERSION} \
    docker.d/ide
}

rm_servers_configuration_files_in_build_context() {
  rm -f \
    docker.d/ide/authserver.conf \
    docker.d/ide/worldserver.conf
}

main() {
  rm_servers_configuration_files_in_build_context \
  && fetch_servers_configuration_files_in 'docker.d/ide' \
  && patch_configuration_file_in_build_context \
  && build_image
}

main

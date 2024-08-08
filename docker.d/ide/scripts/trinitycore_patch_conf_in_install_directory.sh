# TODO: duplicated code
get_real_install_directory() {
  echo "${TRINITYCORE_INSTALL_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

# TODO: duplicated code
get_real_source_directory() {
  echo "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

apply_worldserver_patch() {
  patch "$(get_real_install_directory)/etc/worldserver.conf" << EOF
67c67
< RealmID = 1
---
> RealmID = ${DEBUG_REALM_ID}
76c76
< DataDir = "/home/trinitycore/trinitycore/data"
---
> DataDir = "${USER_HOME_DIR}/client_data"
110,112c110,112
< LoginDatabaseInfo     = "databases;3306;trinity;trinity;auth"
< WorldDatabaseInfo     = "databases;3306;trinity;trinity;world"
< CharacterDatabaseInfo = "databases;3306;trinity;trinity;characters"
---
> LoginDatabaseInfo     = "databases;3306;trinity;trinity;${DEBUG_AUTH_DATABASE_NAME}"
> WorldDatabaseInfo     = "databases;3306;trinity;trinity;${DEBUG_WORLD_DATABASE_NAME}"
> CharacterDatabaseInfo = "databases;3306;trinity;trinity;${DEBUG_CHARACTERS_DATABASE_NAME}"
154c154
< WorldServerPort = 8085
---
> WorldServerPort = ${DEBUG_WORLDSERVER_PORT}
202c202
< SourceDirectory  = "/home/trinitycore/TrinityCore"
---
> SourceDirectory  = "$(get_real_source_directory)"
3012c3012
< Console.Enable = 0
---
> Console.Enable = 1
3049c3049
< SOAP.Enabled = 1
---
> SOAP.Enabled = 0
3056c3056
< SOAP.IP = "0.0.0.0"
---
> SOAP.IP = "127.0.0.1"
EOF
}

apply_authserver_patch() {
  patch "$(get_real_install_directory)/etc/authserver.conf" << EOF
56c56
< RealmServerPort = 3724
---
> RealmServerPort = ${DEBUG_AUTHSERVER_PORT}
157c157
< SourceDirectory  = "/home/trinitycore/TrinityCore"
---
> SourceDirectory  = "$(get_real_source_directory)"
207c207
< LoginDatabaseInfo = "databases;3306;trinity;trinity;auth"
---
> LoginDatabaseInfo = "databases;3306;trinity;trinity;${DEBUG_AUTH_DATABASE_NAME}"
EOF
}

install_configuration_files() {
  mkdir -p "$(get_real_install_directory)/etc"

  cp -f \
    "${USER_HOME_DIR}/trinitycore_configurations/authserver.conf" \
    "${USER_HOME_DIR}/trinitycore_configurations/worldserver.conf" \
    "$(get_real_install_directory)/etc"
}

main() {
  install_configuration_files \
  && apply_worldserver_patch \
  && apply_authserver_patch
}

main

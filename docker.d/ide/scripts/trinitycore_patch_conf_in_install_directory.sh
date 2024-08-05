get_real_install_directory() {
  echo "${TRINITYCORE_INSTALL_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

ensure_conf_file_exists() {
  local file="$(get_real_install_directory)/etc/$1"

  if [ ! -f "${file}" ]; then
    cat << EOF
Fatal: The ${file} file does not exist.
------ You can create it from template in the
${TRINITYCORE_INSTALL_DIRECTORY}/etc directory.
Alternatively, you can extract the configuration files from docker images such
as ${NAMESPACE}.authserver:${AUTHSERVER_VERSION} or
${NAMESPACE}.worldserver:${WORLDSERVER_VERSION} should you have built them with
the trinitycore-in-docker project. First, change your current directory to the
root directory of the trinitycore-in-docker repository. Then, issue the
following command to proceed:

  make extract_conf

If everything is going well, you should have both worldserver.conf and
authserver.conf files in your current directory.
Copy them to ${TRINITYCORE_INSTALL_DIRECTORY}/etc and restart this script to
patch them automatically.
EOF

  return 1
  fi
}

apply_worldserver_patch() {
  patch "$(get_real_install_directory)/etc/worldserver.conf" << EOF
76c76
< DataDir = "/home/trinitycore/trinitycore/data"
---
> DataDir = "${USER_HOME_DIR}/client_data"
1368c1368
< Updates.EnableDatabases = 7
---
> Updates.EnableDatabases = 0
1376c1376
< Updates.AutoSetup   = 1
---
> Updates.AutoSetup   = 0
1385c1385
< Updates.Redundancy  = 1
---
> Updates.Redundancy  = 0
1402c1402
< Updates.AllowRehash = 1
---
> Updates.AllowRehash = 0
1414c1414
< Updates.CleanDeadRefMaxCount = 3
---
> Updates.CleanDeadRefMaxCount = 0
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

patch_worldserver_conf() {
  ensure_conf_file_exists worldserver.conf \
  && apply_worldserver_patch
}

apply_authserver_patch() {
  patch "$(get_real_install_directory)/etc/authserver.conf" << EOF
258c258
< Updates.EnableDatabases = 1
---
> Updates.EnableDatabases = 0
266c266
< Updates.AutoSetup   = 1
---
> Updates.AutoSetup   = 0
275c275
< Updates.Redundancy  = 1
---
> Updates.Redundancy  = 0
292c292
< Updates.AllowRehash = 1
---
> Updates.AllowRehash = 0
304c304
< Updates.CleanDeadRefMaxCount = 3
---
> Updates.CleanDeadRefMaxCount = 0
EOF
}

patch_authserver_conf() {
  ensure_conf_file_exists authserver.conf \
  && apply_authserver_patch
}

main() {
  patch_worldserver_conf \
  && patch_authserver_conf
}

main

#! /bin/sh

delete_admin_account() {
  /home/worldserver_remote_access/scripts/execute_console_command.sh \
    'account delete '"$(cat '/home/worldserver_remote_access/.admin_account_name')"

  exit $?
}

setup_signal_handling() {
  trap delete_admin_account INT QUIT HUP TERM
}

generate_random_acount_credentials_string() {
  local file="$1"

  dd if=/dev/urandom ibs=1 count=12 2> /dev/null \
  | base64 \
  | tr '[:lower:]' '[:upper:]' \
  | tr -d '\n'
}

wait_for_worldserver() {
  until /home/worldserver_remote_access/scripts/healthcheck.sh; do
    sleep 1
  done
}

create_transient_admin_account() {
  local account_name="$(generate_random_acount_credentials_string)"
  local account_password="$(generate_random_acount_credentials_string)"

  /home/worldserver_remote_access/scripts/execute_console_command.sh \
    'account create '"${account_name}"' '"${account_password}" > /dev/null \
  && /home/worldserver_remote_access/scripts/execute_console_command.sh \
    'account set addon '"${account_name}"' 2' > /dev/null \
  && /home/worldserver_remote_access/scripts/execute_console_command.sh \
    'account set gm '"${account_name}"' 3' > /dev/null

  echo "${account_name}"
  echo "${account_password}"
}

store_admin_credential_in_file() {
  local credential="$1"
  local file="$2"

  echo "${credential}" \
  | tr -d '\n' > "${file}"
}

store_admin_credentials_in_files() {
  local account_name_set=false

  while read input; do
    if [ "${account_name_set}" = 'false' ]; then
      store_admin_credential_in_file \
        "${input}" \
        '/home/worldserver_remote_access/.admin_account_name'

      account_name_set=true
    else
      store_admin_credential_in_file \
        "${input}" \
        '/home/worldserver_remote_access/.admin_account_password'

      return 0
    fi
  done
}

delete_bootstrap_admin_account() {
  /home/worldserver_remote_access/scripts/execute_console_command.sh \
    'account delete TC_ADMIN'
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  setup_signal_handling \
  && wait_for_worldserver \
  && create_transient_admin_account \
  |  store_admin_credentials_in_files \
  && delete_bootstrap_admin_account \
  && run_live_loop
}

main

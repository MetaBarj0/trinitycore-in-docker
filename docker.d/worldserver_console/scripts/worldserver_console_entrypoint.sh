#! /bin/sh

check_admin_credentials() {
  if [ -z "${ADMIN_ACCOUNT_NAME}" ] || [ -z "${ADMIN_ACCOUNT_PASSWORD}" ]; then
    echo 'FATAL: administrator account creadentials must be set' >&2
    echo '       ADMIN_ACCOUNT_NAME and ADMIN_ACCOUNT_PASSWORD must be set.' >&2

    exit 1
  fi

  local name="$(echo ${ADMIN_ACCOUNT_NAME} | tr '[:lower:]' '[:upper:]')";
  local password="$(echo ${ADMIN_ACCOUNT_PASSWORD} | tr '[:lower:]' '[:upper:]')";

  if [ "${name}" = 'TC_ADMIN' ] || [ "${password}" = 'TC_ADMIN' ]; then
    echo 'FATAL: security issue with admin account credentials!'
    echo 'Do not use neither the bootstrap account name nor password.'

    exit 1
  fi

  ADMIN_ACCOUNT_NAME="${name}"
  ADMIN_ACCOUNT_PASSWORD="${password}"
}

create_admin_account_credentials() {
  CREATED_ADMIN_ACCOUNT_NAME="${ADMIN_ACCOUNT_NAME}"
  CREATED_ADMIN_ACCOUNT_PASSWORD="${ADMIN_ACCOUNT_PASSWORD}"
}

use_bootstrap_admin_account() {
  ADMIN_ACCOUNT_NAME=TC_ADMIN
  ADMIN_ACCOUNT_PASSWORD=TC_ADMIN
}

wait_for_worldserver() {
  until /home/worldserver_console/scripts/healthcheck.sh; do
    sleep 1
  done
}

re_create_admin_account() {
  /home/worldserver_console/scripts/execute_console_command.sh \
    'account delete '"${CREATED_ADMIN_ACCOUNT_NAME}"

  /home/worldserver_console/scripts/execute_console_command.sh \
    'account create '"${CREATED_ADMIN_ACCOUNT_NAME}"' '"${CREATED_ADMIN_ACCOUNT_PASSWORD}"

  /home/worldserver_console/scripts/execute_console_command.sh \
    'account set addon '"${CREATED_ADMIN_ACCOUNT_NAME}"' 2'

  /home/worldserver_console/scripts/execute_console_command.sh \
    'account set gm '"${CREATED_ADMIN_ACCOUNT_NAME}"' 3'
}

use_created_admin_account() {
  ADMIN_ACCOUNT_NAME="${CREATED_ADMIN_ACCOUNT_NAME}"
  ADMIN_ACCOUNT_PASSWORD="${CREATED_ADMIN_ACCOUNT_PASSWORD}"
}

delete_bootstrap_admin_account() {
  /home/worldserver_console/scripts/execute_console_command.sh \
    'account delete TC_ADMIN'
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  check_admin_credentials
  create_admin_account_credentials

  use_bootstrap_admin_account
    wait_for_worldserver
    re_create_admin_account
  use_created_admin_account

  delete_bootstrap_admin_account

  run_live_loop
}

main

trap shutdown SIGTERM

shutdown() {
  echo Terminating gracefully worldserver_console service...

  exit 0
}

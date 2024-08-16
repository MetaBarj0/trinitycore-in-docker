#!/bin/sh

set -e

kill_mariadb_daemon() {
  echo Terminating gracefully databases service...

  kill %1
}

shutdown() {
  kill_mariadb_daemon

  exit $?
}

setup_signal_handling() {
  trap shutdown INT QUIT HUP TERM
}

install_databases() {
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql/data
}

start_mariadb_daemon() {
  mariadbd-safe --user=mysql --datadir=/var/lib/mysql/data &
}

apply_sql_file() {
  local cmd='mariadb < '"$1"

  while ! eval ${cmd}; do
    sleep 1;
  done
}

install_root_privileges() {
  apply_sql_file '/root/sql/root_privileges.sql'
}

patch_create_mysql_script() {
  cd /root/sql > /dev/null

  patch create_mysql.sql /root/diffs/sql/create_mysql.sql.diff

  cd - > /dev/null
}

apply_trinitycore_databases_creation_script() {
  apply_sql_file '/root/sql/create_mysql.sql'
}

create_trinitycore_databases() {
  patch_create_mysql_script \
  && apply_trinitycore_databases_creation_script
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  setup_signal_handling \
  && install_databases \
  && start_mariadb_daemon \
  && install_root_privileges \
  && create_trinitycore_databases \
  && run_live_loop
}

main

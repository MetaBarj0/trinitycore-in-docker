#!/bin/sh

set -e

# TODO; handle depreacation warning send by mariadb at start
install_databases() {
  mysql_install_db --user=mysql --datadir=/var/lib/mysql/data
}

start_mysql_daemon() {
  mysqld_safe --user=mysql --datadir=/var/lib/mysql/data &
}

apply_sql_file() {
  local cmd='mysql < '"$1"

  while ! eval ${cmd}; do
    sleep 1;
  done
}

install_root_privileges() {
  apply_sql_file '/root/sql/root_privileges.sql'
}

patch_create_mysql_script() {
  cd /root/sql

  cp /root/TrinityCore/sql/create/create_mysql.sql .
  patch create_mysql.sql /root/diffs/sql/create_mysql.sql.diff

  cd -
}

apply_trinitycore_databases_creation_script() {
  apply_sql_file '/root/sql/create_mysql.sql'
}

create_trinitycore_databases() {
  patch_create_mysql_script
  apply_trinitycore_databases_creation_script
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

main() {
  install_databases
  start_mysql_daemon
  install_root_privileges
  create_trinitycore_databases
  run_live_loop
}

main

trap shutdown SIGTERM

kill_mysql_daemon() {
  echo Terminating gracefully databases service...

  kill %1
}

shutdown() {
  kill_mysql_daemon

  exit 0
}

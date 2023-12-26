#!/bin/sh

install_databases() {
  mysql_install_db --user=mysql --datadir=/var/lib/mysql/data
}

start_mysql_daemon() {
  mysqld_safe --user=mysql --datadir=/var/lib/mysql/data &
}

install_root_privileges() {
  local cmd='mysql < /root/root-privileges.sql'

  while ! eval ${cmd}; do
    sleep 1;
  done
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


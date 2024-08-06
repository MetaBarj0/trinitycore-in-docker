#!/bin/sh

lsphp83 \
  /home/worldserver_remote_access/scripts/execute_console_command.php \
  "server info" \
  | grep TrinityCore

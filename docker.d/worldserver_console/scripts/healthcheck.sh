#!/bin/sh

lsphp83 \
  /home/worldserver_console/scripts/execute_console_command.php \
  "server info" \
  | grep TrinityCore

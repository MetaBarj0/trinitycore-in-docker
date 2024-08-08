#!/bin/env bash

setup_ssh_keys() {
  cd

  mkdir -m 700 .ssh
  cat /run/secrets/ide_ssh_public_key > .ssh/id_rsa.pub
  cat /run/secrets/ide_ssh_secret_key > .ssh/id_rsa
  chmod -R 600 .ssh/id_rsa*

  cd -
}

setup_git_user() {
  git config --global user.email "${GIT_USER_EMAIL}"
  git config --global user.name "${GIT_USER_NAME}"

}

run_live_loop() {
  while true; do
    sleep 1
  done
}

setup_motd() {
  local motd_command=\
"cat << EOF
Welcome into the trinitycore-in-docker ide service.
To begin with your development endeavors you can:

01. clone the configure TrinityCore repository with:
     'trinitycore_clone.sh' command.
02. use 'neovim' as IDE.
03. configure the build with cmake:
     'cmake -G Ninja ...'
   (see official doc or trinitycore-in-docker Dockerfiles for examples)
04. build the whole thing with cmake:
     'cmake --target all --build ...'
   (see official doc or trinitycore-in-docker Dockerfiles for examples)
05. install debug version of tools and servers with cmake:
     'cmake --target install --build ...'
   (see official doc or trinitycore-in-docker Dockerfiles for examples)
06. patch configuration file to make them suitable for debugging purposes with
   the following command:
     'trinitycore_patch_conf_in_install_directory.sh'
07. start trinitycore-in-docker databases service with the following command:
     'make up service=databases'
08. Ensure debug databases are created with the following command:
     'trinitycore_ensure_debug_databases_exist.sh'
09. start your debug versions of servers
10. Enjoy the debug environment (lldb + supercharged neovim)
EOF
"

  echo "${motd_command}" >> .bashrc
}

main() {
  setup_ssh_keys \
  && setup_git_user \
  && setup_motd \
  && run_live_loop
}

main

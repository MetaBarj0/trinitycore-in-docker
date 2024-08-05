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

- clone the configure TrinityCore repository with:
  'trinitycore_clone.sh' command
- use 'neovim' as IDE.
- build the whole thing either:
  - using trinitycore-in-docker
  - manually with cmake
- start trinitycore-in-docker game servers with the following command:
  'make up'
- install debug version of tools and servers with cmake
- patch configuration file to make them suitable for debugging purposes with
  the 'trinitycore_patch_conf_in_install_directory.sh' command
- start your debug versions of servers
- debug the stuff
- ...
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

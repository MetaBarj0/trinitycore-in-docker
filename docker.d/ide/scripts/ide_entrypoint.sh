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

source_scripts() {
  . "${USER_HOME_DIR}/scripts/trinitycore_clone.sh"
}

display_motd() {
  cat << EOF
Welcome into the trinitycore-in-docker development environment.
To begin with you development endeavors you can:

- Clone the configure TrinityCore repository with:
  \`trinitycore_clone.sh\` command
- Use \`neovim\` as IDE.
EOF
}

main() {
  setup_ssh_keys \
  && setup_git_user \
  && source_scripts \
  && display_motd \
  && run_live_loop
}

main

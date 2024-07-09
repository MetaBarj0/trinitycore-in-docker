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

copy_repository_from_builder() {
  cd ~/ide_storage

  if ! [ -d TrinityCore ]; then
    docker run \
      -u trinitycore --rm -it --entrypoint /bin/bash -d --name trinitycore.builder.container \
      ${NAMESPACE}.trinitycore.builder:${BUILDER_VERSION}
    docker cp trinitycore.builder.container:/home/trinitycore/TrinityCore .
    docker kill trinitycore.builder.container
  fi

  cd -
}

unshallow_repository() {
  cd ~/ide_storage/TrinityCore

  rm .git/shallow.lock
  git fetch --unshallow
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git fetch
  git config url."git@github.com:".insteadOf "https://github.com/"

  cd -
}

setup_repository() {
  copy_repository_from_builder
  unshallow_repository
}

run_live_loop() {
  while true; do
    sleep 1
  done
}

# TODO: chain function in all scripts
main() {
  setup_ssh_keys
  setup_git_user
  setup_repository  
  run_live_loop
}

main

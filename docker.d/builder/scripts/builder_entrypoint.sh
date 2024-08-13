#!/bin/env bash
set -e

patch_authserver_configuration() {
  cd docker.d/gameservers/patches/configuration

  patch \
    ${USER_HOME_DIR}/trinitycore_configurations/authserver.conf \
    authserver.conf.diff

  cd -
}

archive_configuration_files() {
  . trinitycore_scripts/archive.sh

  cd trinitycore_configurations

  archive_files_to \
    Makefile.env \
    Makefile.maintainer.env \
    authserver.conf \
    worldserver.conf \
    ../docker.d/gameservers/configuration_files.tar

  cd -
}

copy_authserver_configuration_in_gameservers_build_context() {
  cp \
    trinitycore_configurations/authserver.conf \
    docker.d/gameservers/
}

prepare_authserver_configuration() {
  patch_authserver_configuration \
  && copy_authserver_configuration_in_gameservers_build_context
}

generate_Cameras_dbc_and_maps_in_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  rm -rf Cameras dbc maps
  rm -f mapextractor
  cp /home/trinitycore/trinitycore/bin/mapextractor .
  ./mapextractor

  cd -
}

store_Cameras_dbc_and_maps_from_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  local client_data_store_dir=${USER_HOME_DIR}/data

  rm -rf $client_data_store_dir/Cameras
  rm -rf $client_data_store_dir/dbc
  rm -rf $client_data_store_dir/maps
  cp -r Cameras dbc maps $client_data_store_dir

  cd -
}

is_Cameras_dbc_maps_store_set() {
  local store_dir=${USER_HOME_DIR}/data
  local Cameras_dir=$store_dir/Cameras
  local dbc_dir=$store_dir/dbc
  local maps_dir=$store_dir/maps

  if ! [ -d "$Cameras_dir" ] || ! [ -d "$dbc_dir" ] || ! [ -d "$maps_dir" ]; then
    return 1
  fi
}

regenerate_Cameras_dbc_and_maps() {
  generate_Cameras_dbc_and_maps_in_client_dir \
  && store_Cameras_dbc_and_maps_from_client_dir
}

store_Cameras_dbc_and_maps() {
  if ! is_Cameras_dbc_maps_store_set; then
    regenerate_Cameras_dbc_and_maps
  fi
}

generate_Cameras_dbc_and_maps() {
  if [ ! $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_Cameras_dbc_and_maps
  fi

  store_Cameras_dbc_and_maps
}

generate_vmaps_in_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  rm -rf Buildings
  rm -f vmap4extractor
  cp /home/trinitycore/trinitycore/bin/vmap4extractor .
  ./vmap4extractor

  rm -rf vmaps
  rm -f vmap4assembler
  cp /home/trinitycore/trinitycore/bin/vmap4assembler .
  mkdir vmaps
  ./vmap4assembler Buildings vmaps

  cd -
}

store_vmaps_from_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  local client_data_store_dir=${USER_HOME_DIR}/data
  rm -rf $client_data_store_dir/vmaps
  cp -r vmaps $client_data_store_dir

  cd -
}

regenerate_vmaps() {
  generate_vmaps_in_client_dir \
  && store_vmaps_from_client_dir
}

is_vmaps_store_set() {
  local store_dir=${USER_HOME_DIR}/data
  local vmaps_dir=$store_dir/vmaps

  if [ ! -d "$vmaps_dir" ]; then
    return 1
  fi
}

store_vmaps() {
  if ! is_vmaps_store_set; then
    regenerate_vmaps
  fi
}

generate_vmaps() {
  if [ ! $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_vmaps
  fi

  store_vmaps
}

generate_mmaps_in_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  rm -rf mmaps
  rm -f mmaps_generator
  cp /home/trinitycore/trinitycore/bin/mmaps_generator .
  mkdir mmaps
  ./mmaps_generator

  cd -
}

store_mmaps_from_client_dir() {
  if is_within_wsl2_container; then
    cd wsl2_client_copy/WoW-3.3.5a-12340/
  else
    cd WoW-3.3.5a-12340/
  fi

  local client_data_store_dir=${USER_HOME_DIR}/data
  rm -rf $client_data_store_dir/mmaps
  cp -r mmaps $client_data_store_dir

  cd -
}

is_mmaps_store_set() {
  local store_dir=${USER_HOME_DIR}/data
  local mmaps_dir=$store_dir/mmaps

  if ! [ -d "$mmaps_dir" ]; then
    return 1
  fi
}

regenerate_mmaps() {
  generate_mmaps_in_client_dir \
  && store_mmaps_from_client_dir
}

store_mmaps() {
  if ! is_mmaps_store_set; then
    regenerate_mmaps
  fi
}

generate_mmaps() {
  if [ ! $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_mmaps
  fi

  store_mmaps
}

generate_client_data() {
  generate_Cameras_dbc_and_maps \
  && generate_vmaps \
  && generate_mmaps
}

patch_worldserver_configuration() {
  cd docker.d/gameservers/patches/configuration

  patch \
    ${USER_HOME_DIR}/trinitycore_configurations/worldserver.conf \
    worldserver.conf.diff

  cd -
}

copy_worldserver_configuration_in_gameservers_build_context() {
  cp \
    trinitycore_configurations/worldserver.conf \
    docker.d/gameservers/
}

prepare_worldserver_configuration() {
  patch_worldserver_configuration \
  && copy_worldserver_configuration_in_gameservers_build_context
}

is_within_wsl2_container() {
  uname -a | grep WSL2 > /dev/null
}

# TODO: remove volume, copy to container
copy_data_to_wsl2_container_if_needed() {
  if is_within_wsl2_container; then
    cd WoW-3.3.5a-12340

    rsync -avz --delete --progress --files-from ../client_files.txt . ../wsl2_client_copy/WoW-3.3.5a-12340

    cd -
  fi
}

build_gameservers_image() {
  docker build \
    --build-arg BUILDER_IMAGE=${BUILDER_IMAGE} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    --build-arg SERVERBASE_VERSION=${SERVERBASE_VERSION} \
    -f docker.d/gameservers/gameservers.Dockerfile \
    -t ${GAMESERVERS_IMAGE_TAG} \
    docker.d/gameservers
}

create_gameservers_image() {
  copy_data_to_wsl2_container_if_needed \
  && generate_client_data \
  && prepare_worldserver_configuration \
  && prepare_authserver_configuration \
  && archive_configuration_files \
  && build_gameservers_image
}

main() {
  create_gameservers_image
}

main

#!/bin/env bash
set -e

patch_authserver_configuration() {
  cd docker.d/authserver/patches/configuration

  patch \
    ~/trinitycore_configurations/authserver.conf \
    authserver.conf.diff

  cd -
}

copy_authserver_configuration_in_authserver_build_context() {
  cp \
    trinitycore_configurations/authserver.conf \
    docker.d/authserver/
}

prepare_authserver_configuration() {
  patch_authserver_configuration
  copy_authserver_configuration_in_authserver_build_context
}

build_authserver_image() {
  docker build \
    --build-arg BUILDER_IMAGE=${BUILDER_IMAGE} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/authserver/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d/authserver
}

create_auth_server_image() {
  prepare_authserver_configuration
  build_authserver_image
}

generate_Cameras_dbc_and_maps_in_client_dir() {
  if [ is_within_wsl2_container ]; then
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
  if [ is_within_wsl2_container ]; then
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
  generate_Cameras_dbc_and_maps_in_client_dir
  store_Cameras_dbc_and_maps_from_client_dir
}

store_Cameras_dbc_and_maps() {
  if ! is_Cameras_dbc_maps_store_set; then
    regenerate_Cameras_dbc_and_maps
  fi
}

generate_Cameras_dbc_and_maps() {
  if ! [ $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_Cameras_dbc_and_maps
  fi

  store_Cameras_dbc_and_maps
}

generate_vmaps_in_client_dir() {
  if [ is_within_wsl2_container ]; then
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
  if [ is_within_wsl2_container ]; then
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
  generate_vmaps_in_client_dir
  store_vmaps_from_client_dir
}

is_vmaps_store_set() {
  local store_dir=${USER_HOME_DIR}/data
  local vmaps_dir=$store_dir/vmaps

  if ! [ -d "$vmaps_dir" ]; then
    return 1
  fi
}

store_vmaps() {
  if ! is_vmaps_store_set; then
    regenerate_vmaps
  fi
}

generate_vmaps() {
  if ! [ $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_vmaps
  fi

  store_vmaps
}

generate_mmaps_in_client_dir() {
  if [ is_within_wsl2_container ]; then
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
  if [ is_within_wsl2_container ]; then
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
  generate_mmaps_in_client_dir
  store_mmaps_from_client_dir
}

store_mmaps() {
  if ! is_mmaps_store_set; then
    regenerate_mmaps
  fi
}

generate_mmaps() {
  if ! [ $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    regenerate_mmaps
  fi

  store_mmaps
}

generate_client_data() {
  generate_Cameras_dbc_and_maps
  generate_vmaps
  generate_mmaps
}

#TODO: well pretty sure it needs a fix
store_trinitycore_sources() {
  cd /home/trinitycore/TrinityCore

  cp -r * ${USER_HOME_DIR}/TrinityCore

  cd -
}

patch_worldserver_configuration() {
  cd docker.d/worldserver/patches/configuration

  patch \
    ${USER_HOME_DIR}/trinitycore_configurations/worldserver.conf \
    worldserver.conf.diff

  cd -
}

copy_worldserver_configuration_in_worldserver_build_context() {
  cp \
    trinitycore_configurations/worldserver.conf \
    docker.d/worldserver/
}

prepare_worldserver_configuration() {
  patch_worldserver_configuration
  copy_worldserver_configuration_in_worldserver_build_context
}

build_worldserver_image() {
  docker build \
    --build-arg BUILDER_IMAGE=${BUILDER_IMAGE} \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/worldserver/worldserver.Dockerfile \
    -t ${WORLDSERVER_IMAGE_TAG} \
    docker.d/worldserver
}

is_within_wsl2_container() {
  uname -a | grep WSL2 > /dev/null
}

copy_data_to_wsl2_container() {
  if [ is_within_wsl2_container ]; then
    cd WoW-3.3.5a-12340

    rsync -avz --delete --progress --files-from ../client_files.txt . ../wsl2_client_copy/WoW-3.3.5a-12340

    cd -
  fi
}

create_world_server_image() {
  copy_data_to_wsl2_container
  generate_client_data
  store_trinitycore_sources
  prepare_worldserver_configuration
  build_worldserver_image
}

# TODO: chain functions
main() {
  create_auth_server_image
  create_world_server_image
}

main

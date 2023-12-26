#!/bin/env bash

set -e

create_auth_server_image() {
  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/authserver/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d/authserver
}

generate_Cameras_dbc_and_maps_in_client_dir() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf Cameras dbc maps
  rm -f mapextractor
  cp /home/trinitycore/trinitycore/bin/mapextractor .
  ./mapextractor

  cd -
}

store_Cameras_dbc_and_maps_from_client_dir() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_store_dir=/home/docker/data

  rm -rf $client_data_store_dir/Cameras
  rm -rf $client_data_store_dir/dbc
  rm -rf $client_data_store_dir/maps
  cp -r Cameras dbc maps $client_data_store_dir

  cd -
}

is_Cameras_dbc_maps_store_set() {
  local store_dir=/home/docker/data
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
  cd /home/docker/WoW-3.3.5a-12340/

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
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_store_dir=/home/docker/data
  rm -rf $client_data_store_dir/vmaps
  cp -r vmaps $client_data_store_dir

  cd -
}

regenerate_vmaps() {
  generate_vmaps_in_client_dir
  store_vmaps_from_client_dir
}

is_vmaps_store_set() {
  local store_dir=/home/docker/data
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
  if ! [ $USE_CACHED_CLIENT_DATA ]; then
    regenerate_vmaps
  fi

  store_vmaps
}

generate_mmaps_in_client_dir() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf mmaps
  rm -f mmaps_generator
  cp /home/trinitycore/trinitycore/bin/mmaps_generator .
  mkdir mmaps
  ./mmaps_generator

  cd -
}

store_mmaps_from_client_dir() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_store_dir=/home/docker/data
  rm -rf $client_data_store_dir/mmaps
  cp -r mmaps $client_data_store_dir

  cd -
}

is_mmaps_store_set() {
  local store_dir=/home/docker/data
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
  if ! [ $USE_CACHED_CLIENT_DATA ]; then
    regenerate_mmaps
  fi

  store_mmaps
}

generate_client_data() {
  generate_Cameras_dbc_and_maps
  generate_vmaps
  generate_mmaps
}

store_trinitycore_sources() {
  cd /home/trinitycore/TrinityCore

  cp -r * /home/docker/TrinityCore

  cd -
}

build_worldserver_image() {
  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    --build-arg CLIENT_PATH=${CLIENT_PATH} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/worldserver/worldserver.Dockerfile \
    -t ${WORLDSERVER_IMAGE_TAG} \
    docker.d/worldserver
}

create_world_server_image() {
  generate_client_data
  store_trinitycore_sources
  build_worldserver_image
}

build_server_base_image() {
  docker build \
    -f docker.d/serverbase/serverbase.Dockerfile \
    -t ${NAMESPACE}.serverbase \
    docker.d/serverbase
}

main() {
  build_server_base_image
  create_auth_server_image
  create_world_server_image
}

main

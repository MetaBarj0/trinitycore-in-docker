#!/bin/env bash

set -e

create_auth_server_image() {
  echo Building authserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    -f docker.d/authserver/authserver.Dockerfile \
    -t ${AUTHSERVER_IMAGE_TAG} \
    docker.d/authserver
}

generate_Cameras_dbc_and_maps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf Cameras dbc maps
  rm -f mapextractor
  cp /home/trinitycore/trinitycore/bin/mapextractor .
  ./mapextractor

  cd -
}

cache_Cameras_dbc_and_maps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_cache_dir=/home/docker/docker.d/worldserver/data

  rm -rf $client_data_cache_dir/Cameras
  rm -rf $client_data_cache_dir/dbc
  rm -rf $client_data_cache_dir/maps
  cp -r Cameras dbc maps $client_data_cache_dir

  cd -
}

is_Cameras_dbc_maps_cache_set() {
  local build_context_dir=/home/docker/docker.d/worldserver
  local Cameras_dir=$build_context_dir/data/Cameras
  local dbc_dir=$build_context_dir/data/dbc
  local maps_dir=$build_context_dir/data/maps

  if ! [ -d "$Cameras_dir" ] || ! [ -d "$dbc_dir" ] || ! [ -d "$maps_dir" ]; then
    return 1
  fi
}

generate_and_cache_Cameras_dbc_and_maps_client_data() {
  generate_Cameras_dbc_and_maps_client_data
  cache_Cameras_dbc_and_maps_client_data
}

put_Cameras_dbc_and_maps_in_build_context_from_cache() {
  if ! is_Cameras_dbc_maps_cache_set; then
    generate_and_cache_Cameras_dbc_and_maps_client_data
  fi
}

put_Cameras_dbc_maps_in_build_context() {
  if ! [ $USE_CACHED_CLIENT_DATA -eq 1 ]; then
    generate_and_cache_Cameras_dbc_and_maps_client_data
  fi

  put_Cameras_dbc_and_maps_in_build_context_from_cache
}

generate_Buildings_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf Buildings
  rm -f vmap4extractor
  cp /home/trinitycore/trinitycore/bin/vmap4extractor .
  ./vmap4extractor

  cd -
}

cache_Buildings_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_cache_dir=/home/docker/docker.d/worldserver/data

  rm -rf $client_data_cache_dir/Buildings
  cp -r Buildings $client_data_cache_dir

  cd -
}

generate_and_cache_Buildings_client_data() {
  generate_Buildings_client_data
  cache_Buildings_client_data
}

is_Buildings_cache_set() {
  local build_context_dir=/home/docker/docker.d/worldserver
  local Buildings_dir=$build_context_dir/data/Buildings

  if ! [ -d "$Buildings_dir" ]; then
    return 1
  fi
}

put_Buildings_in_build_context_from_cache() {
  if ! is_Buildings_cache_set; then
    generate_and_cache_Buildings_client_data
  fi
}

put_Buildings_in_build_context() {
  if ! [ $USE_CACHED_CLIENT_DATA ]; then
    generate_and_cache_Buildings_client_data
  fi

  put_Buildings_in_build_context_from_cache
}

generate_vmaps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf vmaps
  rm -f vmap4assembler
  cp /home/trinitycore/trinitycore/bin/vmap4assembler .
  mkdir vmaps
  ./vmap4assembler Buildings vmaps

  cd -
}

cache_vmaps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_cache_dir=/home/docker/docker.d/worldserver/data
  rm -rf $client_data_cache_dir/vmaps
  cp -r vmaps $client_data_cache_dir

  cd -
}

generate_and_cache_vmaps_client_data() {
  generate_vmaps_client_data
  cache_vmaps_client_data
}

is_vmaps_cache_set() {
  local build_context_dir=/home/docker/docker.d/worldserver
  local vmaps_dir=$build_context_dir/data/vmaps

  if ! [ -d "$vmaps_dir" ]; then
    return 1
  fi
}

put_vmaps_in_build_context_from_cache() {
  if ! is_vmaps_cache_set; then
    generate_and_cache_vmaps_client_data
  fi
}

put_vmaps_in_build_context() {
  if ! [ $USE_CACHED_CLIENT_DATA ]; then
    generate_and_cache_vmaps_client_data
  fi

  put_vmaps_in_build_context_from_cache
}

generate_mmaps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  rm -rf mmaps
  rm -f mmaps_generator
  cp /home/trinitycore/trinitycore/bin/mmaps_generator .
  mkdir mmaps
  ./mmaps_generator

  cd -
}

cache_mmaps_client_data() {
  cd /home/docker/WoW-3.3.5a-12340/

  local client_data_cache_dir=/home/docker/docker.d/worldserver/data
  rm -rf $client_data_cache_dir/mmaps
  cp -r mmaps $client_data_cache_dir

  cd -
}

is_mmaps_cache_set() {
  local build_context_dir=/home/docker/docker.d/worldserver
  local mmaps_dir=$build_context_dir/data/mmaps

  if ! [ -d "$mmaps_dir" ]; then
    return 1
  fi
}

generate_and_cache_mmaps_client_data() {
  generate_mmaps_client_data
  cache_mmaps_client_data
}

put_mmaps_in_build_context_from_cache() {
  if ! is_mmaps_cache_set; then
    generate_and_cache_mmaps_client_data
  fi
}

put_mmaps_in_build_context() {
  if ! [ $USE_CACHED_CLIENT_DATA ]; then
    generate_and_cache_mmaps_client_data
  fi

  put_mmaps_in_build_context_from_cache
}

generate_client_data() {
  put_Cameras_dbc_maps_in_build_context
  put_Buildings_in_build_context
  put_vmaps_in_build_context
  put_mmaps_in_build_context
}

build_worldserver_image() {
  echo Building worldserver docker image...

  docker build \
    --build-arg SERVERS_AND_TOOLS_BUILDER_IMAGE=${SERVERS_AND_TOOLS_BUILDER_IMAGE} \
    --build-arg CLIENT_PATH=${CLIENT_PATH} \
    -f docker.d/worldserver/worldserver.Dockerfile \
    -t ${WORLDSERVER_IMAGE_TAG} \
    docker.d/worldserver
}

create_world_server_image() {
  generate_client_data
  build_worldserver_image
}

main() {
  create_auth_server_image
  create_world_server_image
}

main

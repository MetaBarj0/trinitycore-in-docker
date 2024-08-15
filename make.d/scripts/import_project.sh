validate_archive() {
  tar tf "${archive}" \
  | grep images.tar > /dev/null \
  && tar tf "${archive}" \
  | grep volumes.tar >/dev/null
}

validate_archive_variable() {
  [ -n "${archive}" ] \
  && [ -f "${archive}" ] \
  && validate_archive \
  || (
      echo 'Bad archive file specified' >&2 \
      && echo 'Did you forget to specify the archive variable value?' >&2 \
      && return 1
     )
}

extract_main_archive() {
  tar xf "${archive}" images.tar \
  && tar xf "${archive}" volumes.tar
}

abort_import() {
  rm -rf images.tar \
  && rm -rf volumes.tar

  exit 1
}

ensure_image_does_not_exist() {
  local image_type="$1"
  local archive_file="$(tar -tf images.tar | grep ${image_type})"
  local namespace="$(echo ${archive_file} | sed -E "s/(.+)\.${image_type}:.+/\1/")"
  local version="$(echo ${archive_file} | sed -E "s/.+\.${image_type}:(.+)\.tar$/\1/")"
  local image_name="${namespace}.${image_type}:${version}"
  local image_id=$(docker image ls -q ${image_name})

  [ -z "${image_id}" ] \
  || (
      echo "Image ${image_name} already exists. Aborting import." >&2 \
      && abort_import
     )
}

ensure_databases_image_does_not_exist() {
  ensure_image_does_not_exist databases
}

ensure_gameservers_image_does_not_exist() {
  ensure_image_does_not_exist gameservers
}

ensure_worldserver_remote_access_image_does_not_exist() {
  ensure_image_does_not_exist worldserver_remote_access
}

ensure_images_do_not_exist() {
  ensure_databases_image_does_not_exist \
  && ensure_gameservers_image_does_not_exist \
  && ensure_worldserver_remote_access_image_does_not_exist
}

ensure_volume_does_not_exists() {
  local volume_kind="$1"
  local archive_file="$(tar -tf volumes.tar | grep ${volume_kind})"
  local compose_project_name="$(echo ${archive_file} | sed -E "s/(.+)_${volume_kind}\.tar$/\1/")"
  local volume_name="${compose_project_name}_${volume_kind}"

  docker volume ls -q | grep ${volume_name}zzz > /dev/null \
  && (
      echo "Volume ${volume_name} already exists. Aborting import." >&2 \
      && abort_import
     ) \
  || return 0
}

ensure_databases_data_volume_does_not_exist() {
  ensure_volume_does_not_exists databases_data
}

ensure_client_data_volume_does_not_exist() {
  ensure_volume_does_not_exists client_data
}

ensure_volume_do_not_exist() {
  ensure_databases_data_volume_does_not_exist \
  && ensure_client_data_volume_does_not_exist
}

ensure_project_may_be_imported() {
  ensure_images_do_not_exist \
  && ensure_volume_do_not_exist
}

import_image() {
  local image_type="$1"
  local image_archive_name="$(tar tf images.tar | grep ${image_type})"
  local image_tag="$(echo ${image_archive_name} | sed -E 's/(.*)\.tar$/\1/')"

  tar xf images.tar "${image_archive_name}" \
  && docker image load -q -i "${image_archive_name}"
}

import_databases_image() {
  import_image databases
}

import_gameservers_image() {
  import_image gameservers
}

import_worldserver_remote_access_image() {
  import_image worldserver_remote_access
}

import_images() {
  import_databases_image \
  && import_gameservers_image \
  && import_worldserver_remote_access_image
}

import_volume_with_image_owner_and_shell() {
  local image_name="$1"
  local owner="$2"
  local shell="$3"
  local volume_type="$4"

  local volume_archive_name="$(tar tf volumes.tar | grep ${volume_type})"
  local volume_name="$(echo ${volume_archive_name} | sed -E 's/(.*)\.tar$/\1/')"

  tar xf volumes.tar "${volume_archive_name}"

  docker volume create "${volume_name}"

  local command="tar xf /host/${volume_archive_name} -C /${volume_name}
chown -R ${owner} /${volume_name}"

  docker run \
    --rm \
    -u root \
    -v "${volume_name}":"/${volume_name}" \
    -v .:/host \
    "${image_name}" \
    ${shell} -c "${command}"
}

import_databases_data_volume() {
  import_volume_with_image_owner_and_shell \
    "${NAMESPACE}.databases:${DATABASES_VERSION}" \
    'mysql:mysql' \
    'ash' \
    databases_data
}

import_client_data_volume() {
  import_volume_with_image_owner_and_shell \
    "${NAMESPACE}.gameservers:${DATABASES_VERSION}" \
    'trinitycore:trinitycore' \
    'bash' \
    client_data
}

import_volumes() {
  import_databases_data_volume \
  && import_client_data_volume
}

import_project() {
  import_images \
  && import_volumes
}

cleanup_images() {
  :
}

cleanup_volumes() {
  :
}

cleanup() {
  cleanup_images \
  && cleanup_volumes
}

main() {
  validate_archive_variable \
  && extract_main_archive \
  && ensure_project_may_be_imported \
  && import_project \
  && cleanup
}

main

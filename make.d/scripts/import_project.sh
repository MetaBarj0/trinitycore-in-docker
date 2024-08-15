validate_archive() {
  tar -tf "${archive}" \
  | grep images.tar > /dev/null \
  && tar tf "${archive}" \
  | grep volumes.tar >/dev/null
}

validate_archive_variable() {
  echo '  validating archive...'

  [ -n "${archive}" ] \
  && [ -f "${archive}" ] \
  && validate_archive \
  || (
      echo 'Bad archive file specified' >&2 \
      && echo 'Did you forget to specify the archive variable value?' >&2 \
      && return 1
     )
}

ensure_image_does_not_exist() {
  local image_type="$1"

  local archive_file="$(cat ${archive} | tar -xO images.tar | tar -tO 2>&1 | grep ${image_type})"
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

ensure_images_do_not_exist() {
  ensure_image_does_not_exist databases \
  && ensure_image_does_not_exist gameservers \
  && ensure_image_does_not_exist worldserver_remote_access
}

ensure_volume_does_not_exists() {
  local volume_kind="$1"

  local archive_file="$(cat ${archive} | tar -xO volumes.tar | tar -tO 2>&1 | grep ${volume_kind})"
  local compose_project_name="$(echo ${archive_file} | sed -E "s/(.+)_${volume_kind}\.tar$/\1/")"
  local volume_name="${compose_project_name}_${volume_kind}"

  docker volume ls -q | grep ${volume_name} > /dev/null \
  && (
      echo "Volume ${volume_name} already exists. Aborting import." >&2 \
      && abort_import
     ) \
  || return 0
}

ensure_volumes_do_not_exist() {
  ensure_volume_does_not_exists databases_data \
  && ensure_volume_does_not_exists client_data
}

ensure_project_may_be_imported() {
  echo '  ensuring project may be imported...'

  ensure_images_do_not_exist \
  && ensure_volumes_do_not_exist
}

abort_import() {
  rm -rf images.tar \
  && rm -rf volumes.tar

  exit 1
}

import_image() {
  local image_type="$1"

  echo "    importing ${image_type} image..."

  local image_archive_name="$(cat ${archive} | tar -xO images.tar | tar -tO 2>&1 | grep ${image_type})"
  local image_tag="$(echo ${image_archive_name} | sed -E 's/(.*)\.tar$/\1/')"

  cat "${archive}" | tar -xO images.tar | tar -xO "${image_archive_name}" | docker image load > /dev/null
}

import_images() {
  import_image databases \
  && import_image gameservers \
  && import_image worldserver_remote_access
}

import_volume_with_image_owner_and_shell() {
  local image_name="$1"
  local owner="$2"
  local shell="$3"
  local volume_kind="$4"

  echo "    importing ${volume_kind} volume..."

  local volume_archive_name="$(cat ${archive} | tar -xO volumes.tar | tar -tO 2>&1 | grep ${volume_kind})"
  local volume_name="$(echo ${volume_archive_name} | sed -E 's/(.*)\.tar$/\1/')"

  docker volume create "${volume_name}" > /dev/null

  local command="cat /${archive} | tar -xO volumes.tar | tar -xO ${volume_archive_name} | tar -C /${volume_name} -x > /dev/null
chown -R ${owner} /${volume_name} > /dev/null"

  docker run \
    --rm \
    -u root \
    -v "${volume_name}":"/${volume_name}" \
    -v "./${archive}":"/${archive}" \
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
  echo '  importing project...'

  import_images \
  && import_volumes
}

main() {
  echo "starting ${archive} project import..."

  validate_archive_variable \
  && ensure_project_may_be_imported \
  && import_project \
  && echo "project successfully imported from ${archive}"
}

main

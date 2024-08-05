is_target_directory_empty_or_inexisting() {
  if [ ! -d "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" ]; then
    return 0
  fi

  local count=$(find "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" -maxdepth 1 -mindepth 1 | wc -l)

  if [ $count -eq 0 ]; then
    rm -r "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}"

    return 0
  else
    return 1
  fi
}

clone_repository() {
  echo "Cloning the TrinityCore repository to ${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}..."

  git clone "${REPOSITORY_URI}" "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}"

  echo "TrinityCore repository clone into ${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}."
}

ensure_target_directory_contains_cloned_repository() {
  cd "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" 2>&1 > /dev/null

  local repository_uri="$(git remote get-url origin 2> /dev/null)"

  cd - 2>&1 > /dev/null

  [ "${repository_uri}" = "${REPOSITORY_URI}" ] \
  && echo "The TrinityCore repository is already cloned into ${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}"
}

output_error_because_of_invalid_target_directory() {
  cat << EOF >&2
Fatal: Invalid target directory for TrinityCore clone.
------ Ensure either:
- the directory targeted by the TRINITYCORE_REPOSITORY_TARGET_DIRECTORY
  variable is empty or inexisting
- or this directory contains the clone of the repository targeted by the
  REPOSITORY_URI variable
EOF

  return 1
}

main() {
  is_target_directory_empty_or_inexisting \
  && clone_repository \
  || ensure_target_directory_contains_cloned_repository \
  || output_error_because_of_invalid_target_directory
}

main

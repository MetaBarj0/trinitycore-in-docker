get_real_install_directory() {
  echo "${TRINITYCORE_INSTALL_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

get_real_source_directory() {
  echo "${TRINITYCORE_REPOSITORY_TARGET_DIRECTORY}" \
  | sed -E "s%^~(/.+)%${USER_HOME_DIR}\1%"
}

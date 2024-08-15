# TODO: enclose file name variables in ""
archive_files_to() {
  local arg_count=$#

  eval "local destination_archive=\$$arg_count"

  local it=1
  local input_files=''

  while [ $it -lt $arg_count ]; do
    eval "local input_file=\$$it"

    input_files="${input_files} ${input_file}"

    it=$(( it + 1 ))
  done

  tar c -f "${destination_archive}" ${input_files}
}

copy_files_in_build_context() {
  local arg_count=$#

  eval "local build_context=\$$arg_count"

  local it=1
  local input_files=''

  while [ $it -lt $arg_count ]; do
    eval "local input_file=\$$it"

    input_files="${input_files} ${input_file}"

    it=$(( it + 1 ))
  done

  cp ${input_files} "${build_context}"
}

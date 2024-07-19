print_usage() {
  local cmd \
    && [ $maintainer_mode -eq 1 ] \
    && cmd='make init maintainer_mode=1' \
    || cmd='make init'

  cat << EOF

  Each question is explained and has an overridable default value specified
  between square brackets.
  Should you have made a mistake, you can execute '${cmd}'
  again to fix the faulty setting value you need.
EOF
}

print_init_maintainer_header() {
  cat << EOF

========================= trinitycore-in-docker maintainer initialization script

  Welcome in the maintainer initializer utility.

  You'll be asked several questions for you to answer in order to initialize
  all settings related to the maintainer mode of your trinitycore-in-docker
  project instance.
  $(print_usage $maintainer_mode)
EOF
}

print_init_header() {
  if [ $maintainer_mode -eq 1 ]; then
    cat << EOF

  Now you'll have to configure general settings for this trinitycore-in-docker
  project instance.
EOF
  else
    cat << EOF

========================= trinitycore-in-docker initialization script

  Welcome in the initializer utility.

  You'll be asked several questions for you to answer in order to initialize
  all general settings of your trinitycore-in-docker project instance.
  $(print_usage $maintainer_mode)
EOF
  fi
}

get_first_empty_line_in_file_from() {
  local file="$1"
  local begin=$2
  local it=$begin

  while ! sed -n -r "$it p" "${file}" | grep -E '^$' > /dev/null; do
    it=$(( it + 1 ))
  done

  echo $it
}

get_first_section_line_in() {
  local file="$1"

  local it=0 \
  && it=$(get_first_empty_line_in_file_from "${file}" 1) \
  && it=$(get_first_empty_line_in_file_from "${file}" $(( it + 1 )))

  echo $(( it + 1 ))
}

extract_sections_in() {
  local file="$1"

  local it \
  && it=$(get_first_section_line_in "${file}")

  sed -n -r "$it,$ p" "${file}"
}

get_top_section_last_line_index() {
  local sections="$1"
  local it=5 # ignore the 4 first line of section header
  local last_line_not_found=0

  while [ $last_line_not_found -eq 0 ]; do
    echo "${sections}" | sed -n "$it p" | grep -E -v '^##+#$' > /dev/null

    last_line_not_found=$?

    it=$(( it + 1 ))
  done

  echo $(( it - 1 ))
}

top_section() {
  local sections="$1"
  local top_section_last_line_index=$(get_top_section_last_line_index "${sections}")
  local section_line_count=$(( top_section_last_line_index - 1 ))

  echo "${sections}" | sed -r -n "1,$section_line_count p"
}

print_section_header() {
  local section="$1"

  echo
  echo "${section}" \
  | sed -n '1,3 p' \
  | sed -E '/^##+##$/ d' \
  | sed -E 's/^# /    /' \
  | sed -E 's/$/ CONFIGURATION\n/'
}

format_section_declarations() {
  local headerless_section="$(echo "${section}" | sed -n '5,$ p')"

  echo "${headerless_section}" \
  | sed -E 's/(^[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*$)/\1=\2/'
}

# TODO: duplication get_top*
get_top_question_last_line_index() {
  local questions="$1"
  local it=1
  local last_line_not_found=0

  while [ $last_line_not_found -eq 0 ]; do
    echo "${questions}" | sed -n "$it p" | grep -E -v '^$' > /dev/null

    last_line_not_found=$?

    it=$(( it + 1 ))
  done

  echo $(( it - 1 ))
}

# TODO: pop duplicated code
top_question() {
  local questions="$1"

  local top_question_last_line_index=$(get_top_question_last_line_index "${questions}")
  local question_line_count=$(( top_question_last_line_index - 1 ))

  echo "${questions}" | sed -n "1,$question_line_count p"
}

# TODO: duplicated code
get_variable_line_index() {
  local body="$1"
  local it=1
  local last_line_not_found=0

  while [ $last_line_not_found -eq 0 ]; do
    echo "${body}" | sed -n "$it p" | grep -E '^#' > /dev/null

    last_line_not_found=$?

    it=$(( it + 1 ))
  done

  echo $(( it - 1 ))
}

get_question_description() {
  local body="$1"
  local variable_line_index=$(get_variable_line_index "${body}")
  local description_line_count=$(( variable_line_index - 1 ))

  echo "${body}" \
  | sed -n "1,$description_line_count p" \
  | sed -E 's/^# /  /'
}

get_question_variable_definition() {
  local body="$1"
  local variable_line_index=$(get_variable_line_index "${body}")

  echo "${body}" \
  | sed -n "$variable_line_index p"
}

get_question_variable_name() {
  local body="$1"

  get_question_variable_definition "${body}" \
  | sed -E 's/(^[^=]+)=.*/\1/'
}

get_question_variable_value() {
  local body="$1"

  get_question_variable_definition "${body}" \
  | sed -E 's/^[^=]+=(.*)/\1/'
}

update_variable_in_file() {
  local file="$1"
  local variable_name="$2"
  local variable_value="$3"

  sed -E -i \
    "s%^${variable_name}\s*=\s*.*\$%${variable_name} = ${variable_value}%" \
    "${file}"
}

ask_question() {
  local body="$1"
  local file="$2"

  local description="$(get_question_description "${body}")"
  local variable_name="$(get_question_variable_name "${body}")"
  local variable_value="$(get_question_variable_value "${body}")"

  echo "  ${variable_name}:"$'\n\n'
  echo "${description}"$'\n'

  read -p \
  "  [${variable_value}]: " \
  ${variable_name}

  eval 'local value=$'"${variable_name}"

  if [ ! -z "$value" ]; then
    update_variable_in_file "${file}" "${variable_name}" "${value}"
  fi
}

pop_question() {
  local questions="$1"
  local it=1

  while ! echo "${questions}" \
          | sed -n -r "$it p" \
          | grep -E '^[^=]+=.*$' > /dev/null; do
    it=$(( it + 1 ))
  done

  it=$(( it + 2 )) # An empty line to pass and onother to reach the next question

  echo "${questions}" \
  | sed -n "$it,$ p"
}

ask_questions_of() {
  local section="$1"
  local file="$2"
  local questions="$(format_section_declarations "${section}")"

  while [ ! -z "${questions}" -a $? -eq 0 ]; do
    local question \
    && question="$(top_question "${questions}")" \
    && ask_question "${question}" "${file}" \
    && questions="$(pop_question "${questions}")"
  done
}

pop_section() {
  local sections="$1"
  local next_section_line_index=$(get_top_section_last_line_index "${sections}")

  echo "${sections}" \
  | sed -n "$next_section_line_index,$ p"
}

ask_maintainer_questions() {
  local sections="$(extract_sections_in Makefile.maintainer.env)"

  while [ ! -z "${sections}" -a $? -eq 0 ]; do
    local section \
    && section="$(top_section "${sections}")" \
    && print_section_header "${section}" \
    && ask_questions_of "${section}" "Makefile.maintainer.env" \
    && sections="$(pop_section "${sections}")"
  done
}

# TODO: duplicated code
ask_general_questions() {
  local sections="$(extract_sections_in Makefile.env)"

  while [ ! -z "${sections}" -a $? -eq 0 ]; do
    local section \
    && section="$(top_section "${sections}")" \
    && print_section_header "${section}" \
    && ask_questions_of "${section}" "Makefile.env" \
    && sections="$(pop_section "${sections}")"
  done
}

init_maintainer() {
  print_init_maintainer_header \
  && ask_maintainer_questions
}

init() {
  print_init_header \
  && ask_general_questions
}

main() {
  make prepare > /dev/null 2>&1

  if [ ${maintainer_mode} -eq 1 ]; then
    init_maintainer

  cat << EOF

The maintainer initialization of this trinitycore-in-docker project instance is
now complete.

You can initiate the build, the launch and the attachement to the ide container
by issuing: \`make ide\`

Happy hacking!
EOF
  fi

  init

  cat << EOF

The general initialization of this trinitycore-in-docker project instance is
now complete.

You may initiate servers and tool build by issuing: \`make build\`

Once the build is done, you may start the beast with: \`make up\`
EOF
}

main

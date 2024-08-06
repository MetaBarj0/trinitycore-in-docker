echo_ext() {
  [ "${SHELL}" = "/bin/sh" ] \
  && echo -e $@ \
  || echo $@

  return 0
}

set_print_cyan() {
  echo_ext '\033[0;36m'
}

set_print_red() {
  echo_ext '\033[1;31m'
}

set_print_green() {
  echo_ext '\033[1;32m'
}

set_print_yellow() {
  echo_ext '\033[1;33m'
}

set_print_blue() {
  echo_ext '\033[1;34m'
}

set_print_purple() {
  echo_ext '\033[1;35m'
}

set_print_light_cyan() {
  echo_ext '\033[1;36m'
}

reset_print_color() {
  echo_ext '\033[0;0m'
}


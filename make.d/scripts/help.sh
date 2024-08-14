. make.d/scripts/color.sh

print_help() {
  cat << EOF

Usage: make <target> where target is one of:

make targets:
-------------
EOF

  set_print_green
  cat << EOF
- help:    display this message.
EOF

  set_print_yellow
  cat << EOF
- init:    Ask you a bunch of questions. Aims to simplify the configuration by
           automatically preparing the project and let you answer questions to
           configure each needed variables in environment variable files.
EOF

  set_print_green
  cat << EOF
- prepare: This target prepares the environment before the build. Its purpose
           is to facilitate the user's life. It will setup then environment by
           creating 'Makefile.env' and 'Makefile.maintainer.env' files from
           templates. It'll also, if needed, automatically fetch authentication
           and world server configuration files from the specified git
           repository URI setup in the environment and places them accordingly
           to setup environment variables in the 'Makefile.env' file. Note that
           even if it does a lot, you still have to provide some environment
           setup such as where to locate the WoW client. Read carefully each
           variable description to correctly setup your environment.
EOF

  set_print_yellow
  cat << EOF
- build:   build docker images for databases, worldserver_remote_access and
           builder in a first time. Then, build the authserver and worldserver
           images.
EOF

  set_print_green
  cat << EOF
- up:      Make TrinityCore servers up and running. You can specify a single
           service to run with the 'service' variable
EOF

  set_print_yellow
  cat << EOF
- down:    shutdown TrinityCore servers, destroys containers.
EOF

  set_print_green
  cat << EOF
- exec:    Execute a worldserver command using the 'worldserver_remote_access'
           service. You must use the 'cmd' variable to specify the worldserver
           command to execute. Example: make exec cmd='server info'
EOF

  if [ $maintainer_mode -eq 1 ]; then
    set_print_light_cyan
    cat << EOF
- config:                          Use this target to check the
                                   'docker-compose.yml' configuration. It is
                                   the same thing as running 'docker compose
                                   config' except that it will evaluate all
                                   variables defined in the 'Makefile'. If the
                                   configuration is incorrect, a diagnastic
                                   will be displayed to help you spot the
                                   culprit. If the configuration is correct,
                                   the entire 'docker-compose.yml' file will be
                                   evaluated.
EOF

  set_print_purple
  cat << EOF
- ps:                              this target show docker container that are
                                   currently running in this compose project.
EOF

  set_print_light_cyan
  cat << EOF
- build_builder:                   build the builder meta builder service
                                   image.
EOF

  set_print_purple
  cat << EOF
- debug_build_builder:             debug the build of the builder service
                                   image. this one like a kind of bootstrap
                                   service that is responsible to build each
                                   TrinityCore servers.
EOF

  set_print_light_cyan
  cat << EOF
- build_databases:                 build the databases service docker image.
EOF

  set_print_purple
  cat << EOF
- debug_build_databases:           debug the build of the databases service
                                   docker image. If something goes wrong while
                                   the databases service image is building, a
                                   debug container will be spawned to help you
                                   troubleshoot the issue.
EOF

  set_print_light_cyan
  cat << EOF
- build_servers_and_tools:         Build the actual server docker images. It
                                   relies on the 'build_builder' make target.
                                   This step can be very long as it may
                                   generate client data such as vmaps and mmaps
                                   if they are not already generated.
EOF

  set_print_purple
  cat << EOF
- build_worldserver_remote_access: build the worldserver remote access console
                                   service. This service allow a user to issue
                                   command to be executed by the worldserver
                                   remotely in a separate container.
EOF

  set_print_light_cyan
  cat << EOF
- build_ide:                       Build the 'ide' service. It is a docker
                                   image that contains everything that is
                                   needed to contribute to TrinityCore project.
                                   Development tools of all sort, utilities,
                                   everything you need will be in this image
                                   for you to work in a completely integrated
                                   environment within a docker container. The
                                   image will also expose docker-in-docker
                                   capabilities to ease test deployments.
EOF

  set_print_purple
  cat << EOF
- shell_ide:                       Attach to a running 'ide' service that is
                                   running in background. Requires the service
                                   to run beforehand (see the 'up_ide' target)
EOF

  set_print_light_cyan
  cat << EOF
- ide:                             A shortcut target that runs build_ide,
                                   up_ide and shell_ide targets.
EOF

  set_print_purple
  cat << EOF
- down_ide:                        Shutdown the 'ide' service and remove the
                                   stopped container.
EOF

  set_print_light_cyan
  cat << EOF
- clean:                           This target is designed to remove all images
                                   of this project. It will remove images that
                                   belong to both this compose project and the
                                   namespace you setup in environment (See the
                                   Makefile.maintainer.env, NAMESPACE and
                                   COMPOSE_PROJECT environment variables).
                                   Besides, it also remove the volume
                                   containing the shallow clone of TrinityCore
                                   git repository.
EOF

  set_print_purple
  cat << EOF
- nuke:                            Implies the 'clean' target. Does all the
                                   'clean' target does. Moreover, it'll destroy
                                   all persistent volumes belonging to both
                                   this compose project and the namespace you
                                   defined (See the Makefile.maintainer.env,
                                   NAMESPACE and COMPOSE_PROJECT environment
                                   variables).
EOF

  set_print_light_cyan
  cat << EOF
- nuke_ide:                        Implies down_ide, that is, removes
                                   containers, networks and also all volumes
                                   related to the ide service.
EOF

  set_print_purple
  cat << EOF
- rebuild:                         A shortcut target that runs clean and build
                                   targets.
EOF

  set_print_light_cyan
  cat << EOF
- logs:                            Display logs of all running services and
                                   follow them.
EOF

  set_print_purple
  cat << EOF
- extract_conf:                    Retrieve all configuration files from built
                                   images. Note that built images are necessary
                                   to retrieve configuration files from. Exits
                                   with an error if any image is missing. The
                                   'worldserver.conf' file is retrieved from
                                   the worldserver image. The 'authserver.conf'
                                   file is retrieved from the authserver image.
                                   'Makefile.env' and 'Makefile.maintainer.env'
                                   are retrieved from any built server image
                                   (database, authserver, worldserver,
                                   worldserver_remote_access). Should any
                                   existing configuration file exist before the
                                   call of this target, they are backed-up to
                                   their respective directories and suffixed
                                   with the '.old' extension
EOF
  fi

  set_print_light_cyan
  cat << EOF
- release_gameservers_image:       Build a release version of the gameservers
                                   image. The produced gameservers images
                                   differs in 2 points from the gameservers
                                   image built by the 'build' target:
                                   - the worldserver configuration disable the
                                     database auto update feature
                                   - The container does not download any
                                     database snapshot for installation
                                     purposes.
                                   It means that databases must have been
                                   populated beforehand. To ensure it is the
                                   case, you can run 'make up' and wait for the
                                   worldserver to be ready at least once. You
                                   can ensure the world server is ready by
                                   issuing 'make exec'. If the output is some
                                   server information, the worldserver is ready
                                   and you can sefely invoke this target.
EOF

  set_print_purple
  cat << EOF
- export_project:                  Export images and volumes necessary to run a
                                   complete trinitycore server. Exported images
                                   are:
                                   - databases
                                   - gameservers
                                   - worldserver_remote_access
                                   Exported volumes are:
                                   - databases_data
                                   - client_data
                                   As such, this target requires the 'build'
                                   and 'release_gameservers_image' targets to
                                   have run beforehand. Moreover, services must
                                   be down.
                                   The result of this exportation is a tar
                                   archive whose the name is:
                                   '${NAMESPACE}.${COMPOSE_PROJECT_NAME}.tar'
                                   If the above file name looks incorrect or
                                   invalid, it is caused by bad values in
                                   either the NAMESPACE or the
                                   COMPOSE_PROJECT_NAME environment variable.
                                   You can change by editing them in the
                                   Makefile.maintainer.env file or with the
                                   following command: make init
                                   'maintainer_mode=1'.
EOF

  reset_print_color

  cat << EOF
Environment:
------------
EOF

  set_print_blue
  cat << EOF
Make sure to have your own copy of the 'Makefile.env' file. You can create your
own from the 'Makefile.env.dist' file located in the 'make.d/env_file'
directory and set all variables according your need and your environment. Each
variables are documented.
To create a copy easily, issue the 'make prepare' command.

The same instructions apply for the 'Makefile.maintainer.env' file. However, as
this file is designed to be modified by maintainers of the
'trinitycore-in-docker' project, you may not need to modify the default values
of the resulting 'Makefile.maintainer.env' file.

Both 'Makefile.env' and 'Makefile.maintainer.env' are expected at the root
directory of this repository. They are git-ignored.
'make prepare' creates a copy at the right place.

You can also use the 'make init' target to guide you alongside you
configuration efforts. The 'maintainer_mode' variable applies for this target
too: 'make init maintainer_mode=1'.
EOF

  reset_print_color
  cat << EOF
Variables:
----------
EOF

  set_print_green
  cat << EOF
There are some variables you can use to customize the bahvior of some targets:

- service:         Applies for the 'up' target. If left uninitialized, the 'up'
                   target will start all game servers services at once. You can
                   initialize the 'service' variable to pick only one service
                   to start: 'make up service=databases' for instance.
- maintainer_mode: setting this variable to '1' will turn on the maintainer
                   mode and alter the bahvior of the 'help' target. It will
                   display supplementary documentation about target considered
                   interesting in the point of view of a maintainer of
                   'trinitycore-in-docker'. Note that even you do not activate
                   explicitely the maintainer mode using this variable, you
                   have nonetheless access to all targets.
                   Example: make help maintainer_mode=1
- cmd:             This variable is useful only for the 'exec' target and
                   specify the command to execute with the
                   'worldserver_remote_access' service.
                   Example: make exec cmd='server info'
                   If you issue the 'make exec' without specifying an explicit
                   value into the 'cmd' variable, the 'server info' command
                   will be executed.
                   Example: make exec
EOF

  reset_print_color
  cat << EOF
TrinityCore servers configuration:
----------------------------------
EOF

  set_print_red
  cat << EOF
You also have to provide configuration files for TrinityCore servers to run
correctly.
There are 2 servers to configure:
- the world server, configured with the 'worldserver.conf' configuration file
- the authentication server, configured with the 'authserver' configuration
  file.
You are responsible to provide those configuration files. If you don't provide
them, servers won't start at all.
In the 'Makefile.env' file, set the:
- WORLDSERVER_CONF_PATH
- AUTHSERVER_CONF_PATH
These variable have to contain either an absolute path or a relative path to
the 'Makefile' file.
They configure 'worldserver' and 'authserver' services accordingly.
Note that some part of the configuration are susceptible to be changed when
containers start, as specified in variable descriptions in the
'Makefile.env.dist' file.
Following targets are of great help to configure your project:
- make init
- make prepare
EOF

}

main() {
  if ! less -r 2> /dev/null; then
    print_help
  else
    print_help \
    | less -r
  fi

  reset_print_color
}

main

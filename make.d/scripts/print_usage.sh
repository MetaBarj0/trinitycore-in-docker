#!/bin/env bash

cat << EOF
********************************************************************************

make targets:
-------------

Usage: make <target> where target is one of:

- help:                      display this message.
- build:                     build docker images for databases and
                             build_servers_and_tools_builder in a first time.
                             Then, build the authserver and worldserver images.
- build_databases:           build the databases service docker image.
- build_servers:             Build the actual server docker images. It
                             relies on the 'build_servers_and_tools_builder'
                             make target. This step can be very long as it may
                             generate client data such as vmaps and mmaps if
                             they are not already generated.
- build_worldserver_console: build the worldserver remote access console
                             service. This service allow a user to issue
                             command to be executed by the worldserver remotely
                             in a separate container.
- up:                        Make TrinityCore servers up and running.
- down:                      shutdown TrinityCore servers, destroys containers.
- exec:                      Execute a worldserver command using the
                             'worldserver_console' service. You must use the
                             'cmd' variable to specify the worldserver command
                             to execute.
                             Example: make exec cmd='server info'
EOF

if ! [ $1 -eq 0 ]; then
  cat << EOF
- ps:                                    this target show docker container that
                                         are currently running in this compose
                                         project.
- config:                                Use this target to check the
                                         'docker-compose.yml' configuration. It
                                         is the same thing as running 'docker
                                         compose config' except that it will
                                         evaluate all variables defined in the
                                         'Makefile'. If the configuration is
                                         incorrect, a diagnastic will be
                                         displayed to help you spot the
                                         culprit. If the configuration is
                                         correct, the entire
                                         'docker-compose.yml' file will be
                                         evaluated.
- build_servers_and_tools_builder:       build the
                                         build_servers_and_tools_builder meta
                                         builder service image. See this one
                                         like a kind of bootstrap service.
- debug_build_databases:                 debug the build of the databases service
                                         docker image. If something goes wrong
                                         while the databases service image is
                                         building, a debug container will be
                                         spawned to help you troubleshoot the
                                         issue.
- debug_build_servers_and_tools_builder: debug the build of the
                                         servers_and_tools_builder service
                                         image.
EOF
fi

cat << EOF

********************************************************************************
EOF

cat << EOF

********************************************************************************

Environment:
------------

Make sure to have your own copy of the 'Makefile.env' file.
You can create your own from the 'Makefile.env.dist' file and set all variables
according your need and your environment.
Each variables are documented.

********************************************************************************

********************************************************************************

Variables:
----------

There are some variables you can use to customize the bahvior of some targets:

- maintainer_mode: setting this variable to '1' will turn of the maintainer
                   mode and alter the bahvior of the 'help' target. It will
                   display supplementary documentation about target considered
                   interesting in the point of view of a maintainer of
                   'trinitycore-in-docker'. Note that even you do not activate
                   explicitely the maintainer mode using this variable, you
                   have nonetheless access to all targets.
                   Example: make help maintainer_mode=1
- cmd:             This variable is useful only for the 'exec' target and specify the
                   command to execute with the 'worldserver_console' service.
                   Example: make exec cmd='server info'

********************************************************************************

********************************************************************************

TrinityCore servers configuration:
----------------------------------

you also have to provide configuration files for TrinityCore servers to run
correctly.
There are 2 servers to configure:
- the world server, configured with the 'worldserver.conf' configuration file
- the authentication server, configured with the 'authserver' configuration
  file.
You are responsible to provide those configuration files. If you don't provide
them, servers won't start at all.

********************************************************************************
EOF


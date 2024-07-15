cat << EOF
********************************************************************************

make targets:
-------------

Usage: make <target> where target is one of:

- help:    display this message.
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
- build:   build docker images for databases, worldserver_console and builder
           in a first time. Then, build the authserver and worldserver images.
- up:      Make TrinityCore servers up and running.
- down:    shutdown TrinityCore servers, destroys containers.
- exec:    Execute a worldserver command using the 'worldserver_console'
           service. You must use the 'cmd' variable to specify the worldserver
           command to execute. Example: make exec cmd='server info'
EOF

if [ ! $maintainer_mode -eq 0 ]; then
  cat << EOF
- config:                    Use this target to check the 'docker-compose.yml'
                             configuration. It is the same thing as running
                             'docker compose config' except that it will
                             evaluate all variables defined in the 'Makefile'.
                             If the configuration is incorrect, a diagnastic
                             will be displayed to help you spot the culprit. If
                             the configuration is correct, the entire
                             'docker-compose.yml' file will be evaluated.
- ps:                        this target show docker container that are
                             currently running in this compose project.
- build_builder:             build the builder meta builder service image. See
- debug_build_builder:       debug the build of the builder service image.
                             this one like a kind of bootstrap service that is
                             responsible to build each TrinityCore servers.
- build_databases:           build the databases service docker image.
- debug_build_databases:     debug the build of the databases service docker
                             image. If something goes wrong while the databases
                             service image is building, a debug container will
                             be spawned to help you troubleshoot the issue.
- build_servers_and_tools:   Build the actual server docker images. It relies
                             on the 'build_builder' make target. This step can
                             be very long as it may generate client data such
                             as vmaps and mmaps if they are not already
                             generated.
- build_worldserver_console: build the worldserver remote access console
                             service. This service allow a user to issue
                             command to be executed by the worldserver remotely
                             in a separate container.
- build_ide:                 Build the 'ide' service. It is a docker image that
                             contains everything that is needed to contribute
                             to TrinityCore project. Development tools of all
                             sort, utilities, everything you need will be in
                             this image for you to work in a completely
                             integrated environment within a docker container.
                             The image will also expose docker-in-docker
                             capabilities to ease test deployments.
- up_ide:                    Spin up the 'ide service' in background. Requires
                             the 'ide' service docker image is built beforehand
                             (see the 'build_ide' target)
- shell_ide:                 Attach to a running 'ide' service that is running
                             in background. Requires the service to run
                             beforehand (see the 'up_ide' target)
- ide:                       A shortcut target that runs build_ide, up_ide and
                             shell_ide targets.
- down_ide:                  Shutdown the 'ide' service and remove the stopped
                             container.
- clean:                     This target is designed to remove all images of
                             this project. It will remove images that belong to
                             both this compose project and the namespace you
                             setup in environment (See the
                             Makefile.maintainer.env, NAMESPACE and
                             COMPOSE_PROJECT environment variables). Besides,
                             it also remove the volume containing the shallow
                             clone of TrinityCore git repository.
- nuke:                      Implies the 'clean' target. Does all the 'clean'
                             target does. Moreover, it'll destroy all
                             persistent volumes belonging to both this compose
                             project and the namespace you defined (See the
                             Makefile.maintainer.env, NAMESPACE and
                             COMPOSE_PROJECT environment variables).
- rebuild:                   A shortcut target that runs clean and build
                             targets.
- logs:                      Display logs of all running services and follow
                             them.
EOF
fi

cat << EOF

********************************************************************************
EOF

cat << EOF

********************************************************************************

Environment:
------------

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

********************************************************************************

********************************************************************************

Variables:
----------

There are some variables you can use to customize the bahvior of some targets:

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
                   'worldserver_console' service.
                   Example: make exec cmd='server info'
                   If you issue the 'make exec' without specifying an explicit
                   value into the 'cmd' variable, the 'server info' command
                   will be executed.
                   Example: make exec

********************************************************************************

********************************************************************************

TrinityCore servers configuration:
----------------------------------

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

********************************************************************************
EOF

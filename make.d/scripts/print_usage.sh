#!/bin/env bash

cat << EOF
********************************************************************************

Usage: make <target> where target is one of:

- help:                            display this message
- build:                           build docker images for databases and
                                   build_servers_and_tools_builder
- build_databases:                 build the databases service docker image.
- build_servers_and_tools_builder: build the build_servers_and_tools_builder
                                   meta builder service image.
EOF

if [ $1 -eq 0 ]; then
  cat << EOF

********************************************************************************
EOF
  exit 0
fi

cat << EOF
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
- debug_build_databases:                 debug the build of the databases service
                                         docker image. If something goes wrong
                                         while the databases service image is
                                         building, a debug container will be
                                         spawned to help you troubleshoot the
                                         issue.
- debug_build_servers_and_tools_builder: debug the build of the
                                         servers_and_tools_builder service
                                         image.

********************************************************************************
EOF

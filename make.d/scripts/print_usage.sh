#!/bin/env bash

cat << EOF
********************************************************************************

Usage: make <target> where target is one of:

- help:              display this message
- build:             build docker images for databases, authserver and
                     worldserver
- build_databases:   build the databases service docker image.
- build_authserver:  build the authentication server docker image.
- build_worldserver: build the world server docker image.

********************************************************************************
EOF

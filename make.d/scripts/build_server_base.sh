#!/bin/env sh

docker build \
  -f docker.d/common/serverbase.Dockerfile \
  -t ${NAMESPACE}.serverbase \
  docker.d/common

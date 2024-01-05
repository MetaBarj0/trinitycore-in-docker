#!/bin/env sh

docker build \
  -f docker.d/common/debian-12-slim-upgraded.Dockerfile \
  -t debian:12-slim-upgraded \
  docker.d/common

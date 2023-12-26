ARG SERVERS_AND_TOOLS_BUILDER_IMAGE

# TODO: refacto, it is duplicated in servers_and_tools_builder.Dockerfile
FROM debian:12.2-slim as base_upgraded
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update -y
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get upgrade -y --no-install-recommends

# TODO: check if it can be refactored regarding world server image creation
FROM base_upgraded as install_dependencies
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libmariadb3 libboost-filesystem1.74.0 libboost-program-options1.74.0 \
  libboost-iostreams1.74.0 libboost-regex1.74.0 libboost-locale1.74.0 \
  libboost-system1.74.0 libboost-chrono1.74.0 libboost-atomic1.74.0

FROM install_dependencies as create_trinitycore_user
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore

FROM $SERVERS_AND_TOOLS_BUILDER_IMAGE as builder

FROM create_trinitycore_user as install_auth_server
USER trinitycore
WORKDIR /home/trinitycore
RUN mkdir -p trinitycore/bin trinitycore/etc
WORKDIR /home/trinitycore/trinitycore
COPY \
  --from=builder \
  /home/trinitycore/trinitycore/bin/authserver \
  bin/authserver
COPY \
  --from=builder \
  /home/trinitycore/trinitycore/etc/authserver.conf.dist \
  etc/authserver.conf.dist
WORKDIR /home/trinitycore

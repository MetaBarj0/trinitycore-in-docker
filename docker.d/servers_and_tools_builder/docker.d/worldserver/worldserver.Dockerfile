ARG SERVERS_AND_TOOLS_BUILDER_IMAGE

# TODO: make a common image, usable by this and authserver
FROM debian:12.2-slim-upgraded as install_dependencies
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
  libboost-system1.74.0 libboost-chrono1.74.0 libboost-atomic1.74.0 \
  libncurses6 libreadline8

FROM install_dependencies as create_trinitycore_user
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore

FROM create_trinitycore_user as install_client_data
COPY \
  --chown=trinitycore:trinitycore \
  data/ /home/trinitycore/trinitycore/data/

FROM $SERVERS_AND_TOOLS_BUILDER_IMAGE as builder

FROM install_client_data as install_worldserver
USER trinitycore
WORKDIR /home/trinitycore
RUN mkdir -p trinitycore/bin trinitycore/etc
WORKDIR /home/trinitycore/trinitycore
COPY \
  --from=builder \
  /home/trinitycore/trinitycore/bin/worldserver \
  bin/worldserver
COPY \
  --from=builder \
  /home/trinitycore/trinitycore/etc/worldserver.conf.dist \
  etc/worldserver.conf.dist
WORKDIR /home/trinitycore
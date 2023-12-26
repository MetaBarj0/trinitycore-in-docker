ARG SERVERS_AND_TOOLS_BUILDER_IMAGE
ARG NAMESPACE

FROM $NAMESPACE.serverbase as install_dependencies
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libncurses6 libreadline8 ca-certificates wget p7zip mariadb-client patch

FROM install_dependencies as create_trinitycore_user
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore

FROM $SERVERS_AND_TOOLS_BUILDER_IMAGE as builder

FROM create_trinitycore_user as install_worldserver
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

FROM install_worldserver
USER trinitycore
WORKDIR /home/trinitycore
COPY \
  --chown=trinitycore:trinitycore \
  --chmod=755 \
  scripts/ ./scripts/
COPY \
  --chown=trinitycore:trinitycore \
  diffs/ ./diffs/
RUN mkdir downloads
VOLUME /home/trinitycore/downloads
RUN mkdir trinitycore/data
VOLUME /home/trinitycore/trinitycore/data
RUN mkdir trinitycore/TrinityCore
VOLUME /home/trinitycore/TrinityCore

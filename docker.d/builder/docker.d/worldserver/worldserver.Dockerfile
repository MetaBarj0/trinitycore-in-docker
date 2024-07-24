ARG BUILDER_IMAGE
ARG NAMESPACE

FROM $NAMESPACE.serverbase AS install_dependencies
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libncurses6 libreadline8 ca-certificates wget p7zip curl jq

FROM $BUILDER_IMAGE AS builder

FROM install_dependencies AS install_worldserver
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
COPY worldserver.conf etc/

FROM install_worldserver
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
USER trinitycore
WORKDIR /home/trinitycore
COPY \
  --chown=trinitycore:trinitycore \
  --chmod=755 \
  scripts/ ./scripts/
COPY \
  --chown=trinitycore:trinitycore \
  sql/ ./sql/
COPY \
  --chown=trinitycore:trinitycore \
  configuration_files.tar .
RUN \
  mkdir -p \
  downloads trinitycore/data TrinityCore
RUN touch \
  downloads/.volume \
  trinitycore/data/.volume \
  TrinityCore/.volume
VOLUME /home/trinitycore/downloads
VOLUME /home/trinitycore/trinitycore/data
VOLUME /home/trinitycore/TrinityCore
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

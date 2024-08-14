ARG BUILDER_IMAGE=InvalidBuilderImage
ARG NAMESPACE=InvalidDefaultNamespace
ARG SERVERBASE_VERSION=InvalidVersion

FROM ${NAMESPACE}.serverbase:${SERVERBASE_VERSION} AS install_dependencies
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libncurses6 libreadline8 ca-certificates wget p7zip curl jq

FROM ${BUILDER_IMAGE} AS builder

FROM scratch AS install_shared_objects
COPY --from=install_dependencies / /
USER trinitycore
WORKDIR /home/trinitycore/trinitycore
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/bin/scripts/ \
  bin/scripts/
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/lib \
  lib/

FROM install_shared_objects AS install_worldserver
USER trinitycore
WORKDIR /home/trinitycore/trinitycore
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/bin/worldserver \
  bin/worldserver
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/etc/worldserver.conf.dist \
  etc/worldserver.conf.dist
COPY \
  --chown=trinitycore:trinitycore \
  worldserver.conf etc/

FROM install_worldserver AS install_authserver
USER trinitycore
WORKDIR /home/trinitycore/trinitycore
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/bin/authserver \
  bin/authserver
COPY \
  --from=builder \
  --chown=trinitycore:trinitycore \
  /home/trinitycore/trinitycore/etc/authserver.conf.dist \
  etc/authserver.conf.dist
COPY \
  --chown=trinitycore:trinitycore \
  authserver.conf etc/

FROM install_authserver
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
  configuration_files.tar .
COPY \
  --chown=trinitycore:trinitycore \
  sql/ ./sql/
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

LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

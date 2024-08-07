ARG BUILDER_IMAGE
ARG NAMESPACE
ARG SERVERBASE_VERSION

FROM ${NAMESPACE}.serverbase:${SERVERBASE_VERSION} AS server_base

FROM ${BUILDER_IMAGE} AS builder

FROM server_base AS install_authserver
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
COPY authserver.conf etc/

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
RUN mkdir trinitycore/TrinityCore
VOLUME /home/trinitycore/TrinityCore
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

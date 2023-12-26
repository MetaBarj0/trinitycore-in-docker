ARG SERVERS_AND_TOOLS_BUILDER_IMAGE
ARG NAMESPACE

FROM $NAMESPACE.serverbase as server_base

FROM $SERVERS_AND_TOOLS_BUILDER_IMAGE as builder

FROM server_base as install_authserver
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
USER trinitycore
WORKDIR /home/trinitycore
COPY \
  --chown=trinitycore:trinitycore \
  --chmod=755 \
  scripts/ ./scripts/
RUN mkdir trinitycore/TrinityCore
VOLUME /home/trinitycore/TrinityCore


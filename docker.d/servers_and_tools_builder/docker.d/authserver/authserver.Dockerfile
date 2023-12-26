ARG SERVERS_AND_TOOLS_BUILDER_IMAGE
ARG NAMESPACE

FROM $NAMESPACE.serverbase as create_trinitycore_user
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore

FROM $SERVERS_AND_TOOLS_BUILDER_IMAGE as builder

FROM create_trinitycore_user as install_authserver
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


FROM alpine:edge
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
# TODO: merge update and upgrade instructions
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update
RUN apk add mariadb mariadb-client patch
COPY configuration/mariadb-server.cnf /etc/my.cnf.d/
WORKDIR /root
COPY sql/root-privileges.sql ./sql/
COPY diffs ./diffs/
COPY --chmod=755 scripts/ ./scripts/
VOLUME /var/lib/mysql
VOLUME /root/TrinityCore
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

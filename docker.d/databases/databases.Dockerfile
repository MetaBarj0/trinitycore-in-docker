FROM alpine:edge
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update \
  && apk add mariadb mariadb-client patch
COPY configuration/mariadb-server.cnf /etc/my.cnf.d/
WORKDIR /root
COPY sql/root_privileges.sql ./sql/
COPY diffs ./diffs/
COPY configuration_files.tar ./
COPY --chmod=755 scripts/ ./scripts/
VOLUME /var/lib/mysql
VOLUME /root/TrinityCore
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

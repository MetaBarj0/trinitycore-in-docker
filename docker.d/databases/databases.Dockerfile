# TODO: don't run with root
FROM alpine:edge
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update
RUN apk add mariadb mariadb-client patch
COPY configuration/mariadb-server.cnf /etc/my.cnf.d/
WORKDIR /root
COPY sql/root-privileges.sql ./sql/
COPY diffs ./diffs/
COPY --chmod=755 scripts/databases-entrypoint.sh ./scripts/databases-entrypoint.sh
VOLUME /var/lib/mysql

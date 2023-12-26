FROM alpine:edge as install_mariadb
RUN \
  --mount=type=cache,target=/var/cache/apk \
  apk update
RUN apk add mariadb mariadb-client
COPY configuration/mariadb-server.cnf /etc/my.cnf.d/
WORKDIR /root
COPY sql/root-privileges.sql .
COPY --chmod=755 scripts/databases-entrypoint.sh .
VOLUME /var/lib/mysql
ENTRYPOINT [ "/root/databases-entrypoint.sh" ]

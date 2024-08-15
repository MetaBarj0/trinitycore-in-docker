FROM alpine:edge AS system
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update \
  && apk add mariadb mariadb-client patch tar

FROM scratch
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
COPY --from=system / /
COPY configuration/mariadb-server.cnf /etc/my.cnf.d/
WORKDIR /root
COPY sql/ sql/
COPY create_mysql.sql sql/
COPY diffs ./diffs/
COPY configuration_files.tar ./
COPY --chmod=755 scripts/ scripts/
VOLUME /var/lib/mysql
ENV USER_HOME_DIR=/root
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

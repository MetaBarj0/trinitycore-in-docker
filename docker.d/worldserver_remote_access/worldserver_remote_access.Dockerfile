FROM alpine:edge AS install_php_for_soap
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update \
  && apk add php83-litespeed php83-soap

FROM scratch AS create_user
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
COPY --from=install_php_for_soap / /
RUN adduser -D worldserver_remote_access
WORKDIR /home/worldserver_remote_access
COPY \
  --chown=worldserver_remote_access:worldserver_remote_access \
  --chmod=755 \
  scripts/ ./scripts
COPY \
  --chown=worldserver_remote_access:worldserver_remote_access \
  configuration_files.tar .
RUN ln -s \
  /home/worldserver_remote_access/scripts/execute_console_command.sh \
  /usr/local/bin/
USER worldserver_remote_access
RUN echo 'TC_ADMIN' | tr -d '\n' > .admin_account_name
RUN echo 'TC_ADMIN' | tr -d '\n' > .admin_account_password
ENV USER_HOME_DIR=/home/worldserver_remote_access
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

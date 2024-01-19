FROM alpine:edge as install_php_for_soap
RUN apk update
RUN apk add php83-litespeed php83-soap

FROM install_php_for_soap as create_user
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
RUN adduser -D worldserver_console
WORKDIR /home/worldserver_console
COPY \
  --chown=worldserver_console:worldserver_console \
  --chmod=755 \
  scripts/ ./scripts
RUN ln -s \
  /home/worldserver_console/scripts/execute_console_command.sh \
  /usr/local/bin/
USER worldserver_console
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

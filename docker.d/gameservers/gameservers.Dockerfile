ARG NAMESPACE=InvalidDefaultNamespace
ARG GAMESERVERS_VERSION=InvalidVersion

FROM ${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
USER trinitycore
WORKDIR /home/trinitycore/trinitycore
COPY \
  --chown=trinitycore:trinitycore \
  authserver.conf worldserver.conf etc/
COPY \
  --chown=trinitycore:trinitycore \
  --chmod=755 \
  scripts/ /home/trinitycore/scripts/
RUN mkdir -p data
RUN touch data/.volume
VOLUME /home/trinitycore/trinitycore/data
WORKDIR /home/trinitycore

LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}
LABEL release=yes

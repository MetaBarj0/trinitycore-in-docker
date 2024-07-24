# TODO: refactor update/upgrade instructions
FROM debian:12-slim
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get upgrade -y --no-install-recommends
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

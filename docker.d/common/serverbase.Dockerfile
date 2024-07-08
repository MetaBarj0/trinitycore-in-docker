ARG PLATFORM_TAG
ARG NAMESPACE

FROM $NAMESPACE.debian$PLATFORM_TAG:12-slim-upgraded AS debian_upgraded
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libmariadb3 libboost-filesystem1.74.0 libboost-program-options1.74.0 \
  libboost-iostreams1.74.0 libboost-regex1.74.0 libboost-locale1.74.0 \
  libboost-system1.74.0 libboost-chrono1.74.0 libboost-atomic1.74.0 \
  mariadb-client

FROM debian_upgraded
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

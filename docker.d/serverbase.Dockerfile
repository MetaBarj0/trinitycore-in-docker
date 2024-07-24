ARG PLATFORM_TAG
ARG NAMESPACE

# TODO: upgrade boost
FROM $NAMESPACE.debian$PLATFORM_TAG:12_slim_upgraded AS debian_upgraded
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libmariadb3 libboost-filesystem1.74.0 libboost-program-options1.74.0 \
  libboost-iostreams1.74.0 libboost-regex1.74.0 libboost-locale1.74.0 \
  libboost-system1.74.0 libboost-chrono1.74.0 libboost-atomic1.74.0 \
  mariadb-client

# TODO: braces around build args
FROM debian_upgraded
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
ARG TRINITYCORE_USER_GID
ARG TRINITYCORE_USER_UID
RUN groupadd -g ${TRINITYCORE_USER_GID} trinitycore
RUN useradd -g ${TRINITYCORE_USER_GID} -u ${TRINITYCORE_USER_UID} -m -s /bin/bash trinitycore
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE
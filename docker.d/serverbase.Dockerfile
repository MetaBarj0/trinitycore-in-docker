ARG NAMESPACE

FROM ${NAMESPACE}.debian:12_slim_upgraded AS debian_upgraded
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libmariadb3 libboost-filesystem1.81.0 libboost-program-options1.81.0 \
  libboost-iostreams1.81.0 libboost-regex1.81.0 libboost-locale1.81.0 \
  libboost-system1.81.0 libboost-chrono1.81.0 libboost-atomic1.81.0 \
  mariadb-client

FROM scratch
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
ARG TRINITYCORE_USER_GID
ARG TRINITYCORE_USER_UID
COPY --from=debian_upgraded / /
RUN groupadd -g ${TRINITYCORE_USER_GID} trinitycore
RUN useradd -g ${TRINITYCORE_USER_GID} -u ${TRINITYCORE_USER_UID} -m -s /bin/bash trinitycore
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

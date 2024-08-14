ARG NAMESPACE
ARG SERVERBASE_VERSION

FROM ${NAMESPACE}.serverbase:${SERVERBASE_VERSION} AS install_prerequisites
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libboost1.81-all-dev libmariadb-dev-compat libssl-dev cmake clang-16 zlib1g-dev \
  libreadline-dev git lld-16 ca-certificates ninja-build libbz2-dev patch
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-16 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-16 100
RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld-16 100

FROM scratch AS install_docker
COPY --from=install_prerequisites / /
USER root
# docker installation for debian
# see:
# https://docs.docker.com/engine/install/debian/#install-using-the-repository
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl gnupg
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

FROM scratch
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
ARG USE_DOCKER_DESKTOP
ARG USER
ARG USER_GID
ARG USER_HOME_DIR
ARG USER_UID
COPY --from=install_docker / /
RUN [ ${USE_DOCKER_DESKTOP} -eq 1 ] && exit 0 || [ ! -z ${USER_GID} ] && groupmod -g ${USER_GID} docker
RUN [ ${USE_DOCKER_DESKTOP} -eq 1 ] && exit 0 || useradd -d ${USER_HOME_DIR} -m -s /bin/bash -g docker ${USER}
RUN [ ${USE_DOCKER_DESKTOP} -eq 1 ] && exit 0 || [ ! -z ${USER_UID} ] && usermod -u ${USER_UID} ${USER}
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

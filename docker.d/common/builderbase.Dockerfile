ARG NAMESPACE

FROM $NAMESPACE.serverbase as install_prerequisites
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libboost-all-dev libmariadb-dev-compat libssl-dev cmake clang-16 zlib1g-dev \
  libreadline-dev git lld-16 ca-certificates ninja-build libbz2-dev patch
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-16 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-16 100
RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld-16 100

FROM install_prerequisites as install_docker
USER root
# docker installation for debian
# see:
# https://docs.docker.com/engine/install/debian/#install-using-the-repository
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates curl gnupg
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

FROM install_docker
ARG DOCKER_GID
ARG DOCKER_UID
ARG USE_DOCKER_DESKTOP
ARG USER_HOME_DIR
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || [ ! -z $DOCKER_GID ] && groupmod -g $DOCKER_GID docker
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || useradd -d $USER_HOME_DIR -m -s /bin/bash -g docker docker
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || [ ! -z $DOCKER_UID ] && usermod -u $DOCKER_UID docker

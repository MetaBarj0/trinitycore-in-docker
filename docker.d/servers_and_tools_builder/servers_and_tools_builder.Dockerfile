FROM debian:12.2-slim-upgraded as install_prerequisites
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libboost-all-dev libmariadb-dev-compat libssl-dev cmake clang-16 zlib1g-dev \
  libreadline-dev git lld-16 ca-certificates ninja-build libbz2-dev patch
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-16 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-16 100
RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld-16 100

FROM install_prerequisites as create_trinitycore_user
RUN groupadd -g 2000 trinitycore
RUN useradd -g 2000 -u 2000 -m -s /bin/bash trinitycore

FROM create_trinitycore_user as clone_repository
USER trinitycore
WORKDIR /home/trinitycore
RUN git clone --branch 3.3.5 --depth=1 \
  https://github.com/TrinityCore/TrinityCore.git

FROM clone_repository as configure_build
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/home/trinitycore/trinitycore \
  -DCONF_DIR=/home/trinitycore/trinitycore/etc \
  -DWITHOUT_METRICS=ON \
  ..

FROM configure_build as cmake_build
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build .

FROM cmake_build as cmake_install
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build . --target install

FROM clone_repository as install
USER trinitycore
WORKDIR /home/trinitycore
COPY --from=clone_repository /home/trinitycore/TrinityCore/ TrinityCore/
COPY --from=cmake_install /home/trinitycore/trinitycore/ trinitycore/

FROM install as install_docker
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

FROM install_docker as create_docker_user_if_not_docker_desktop
ARG DOCKER_GID
ARG DOCKER_UID
ARG USE_DOCKER_DESKTOP
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || [ ! -z $DOCKER_GID ] && groupmod -g $DOCKER_GID docker
# TODO: use USER_HOME_DIR build arg instead of /home/docker
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || useradd -d /home/docker -m -s /bin/bash -g docker docker
RUN [ $USE_DOCKER_DESKTOP -eq 1 ] && exit 0 || [ ! -z $DOCKER_UID ] && usermod -u $DOCKER_UID docker

FROM create_docker_user_if_not_docker_desktop as builder
ARG USER
ARG USER_HOME_DIR
USER $USER
WORKDIR $USER_HOME_DIR
COPY --chown=$USER:$USER docker.d docker.d
# TODO: try without relative path components
COPY --chmod=755 scripts/ ./scripts
RUN mkdir -p data
VOLUME $USER_HOME_DIR/data
RUN mkdir -p TrinityCore
VOLUME $USER_HOME_DIR/TrinityCore
RUN mkdir -p trinitycore_configurations
COPY \
  --chown=$USER:$USER \
  worldserver.conf trinitycore_configurations/
COPY \
  --chown=$USER:$USER \
  authserver.conf trinitycore_configurations/

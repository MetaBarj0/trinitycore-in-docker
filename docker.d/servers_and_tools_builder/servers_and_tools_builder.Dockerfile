FROM debian:12.2-slim-upgraded as install_prerequisites
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libboost-all-dev libmariadb-dev-compat libssl-dev cmake clang-16 zlib1g-dev \
  libreadline-dev git lld-16 ca-certificates ninja-build libbz2-dev
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

FROM configure_build as build
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build .

FROM build as install
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build . --target install

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

FROM install_docker as create_docker_user
ARG DOCKER_GID
ARG DOCKER_UID
RUN [ ! -z $DOCKER_GID ] && groupmod -g $DOCKER_GID docker
RUN useradd -d /home/docker -m -s /bin/bash -g docker docker
RUN [ ! -z $DOCKER_UID ] && usermod -u $DOCKER_UID docker

FROM create_docker_user as builder
USER docker
WORKDIR /home/docker
COPY docker.d docker.d
COPY --chmod=755 scripts/servers_and_tools_builder-entrypoint.sh .

# FROM create_docker_user as trimmed_install
# # authserver
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libmariadb3
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-filesystem1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-program-options1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-iostreams1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-regex1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-locale1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-system1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-chrono1.74.0
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libboost-atomic1.74.0
# # worldserver specifics
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libncurses6
# RUN \
#   --mount=type=cache,target=/var/cache/apt,sharing=locked \
#   --mount=type=cache,target=/var/lib/apt,sharing=locked \
#   apt-get install -y --no-install-recommends \
#   libreadline8
# RUN groupadd -g 1000 trinitycore
# RUN useradd -g 1000 -u 1000 -m -s /bin/bash trinitycore
# WORKDIR /home/trinitycore
# COPY \
#   --chown=trinitycore:trinitycore \
#   --from=install \
#   /home/trinitycore/trinitycore/ ./trinitycore
# USER trinitycore
# 
# FROM scratch
# COPY --from=trimmed_install / /
# RUN exit 1

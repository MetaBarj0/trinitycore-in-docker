FROM debian:12.2-slim as base_upgraded
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update -y
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get upgrade -y --no-install-recommends

FROM base_upgraded as install_prerequisites
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libboost-all-dev libmariadb-dev-compat libssl-dev cmake clang-16 zlib1g-dev \
  libreadline-dev git lld-16 ca-certificates ninja-build libbz2-dev
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-16 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-16 100
RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld-16 100

FROM install_prerequisites as create_builder_user
RUN groupadd -g 1000 builder
RUN useradd -g 1000 -u 1000 -m -s /bin/bash builder

FROM create_builder_user as clone_repository
USER builder
WORKDIR /home/builder
RUN git clone --branch 3.3.5 --depth=1 \
  https://github.com/TrinityCore/TrinityCore.git

FROM clone_repository as configure_build
USER builder
WORKDIR /home/builder/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/builder/TrinityCore/build,uid=1000,gid=1000 \
  cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/home/builder/trinitycore \
  -DCONF_DIR=/home/builder/trinitycore/etc \
  -DWITHOUT_METRICS=ON \
  ..

FROM configure_build as build
USER builder
WORKDIR /home/builder/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/builder/TrinityCore/build,uid=1000,gid=1000 \
  cmake --build .

FROM build as install
USER builder
WORKDIR /home/builder/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/builder/TrinityCore/build,uid=1000,gid=1000 \
  cmake --build . --target install

FROM alpine:edge as install_dependencies
RUN \
  --mount=type=cache,target=/var/cache/apk,sharing=locked \
  apk update
RUN apk add boost-dev mariadb-dev openssl-dev cmake clang zlib git ninja-build \
  readline-dev lld
RUN ln -s /usr/lib/ninja-build/bin/ninja /usr/local/bin/ninja

FROM install_dependencies as clone_repository
RUN \
  git clone --branch 3.3.5 --depth=1 \
  https://github.com/TrinityCore/TrinityCore.git

FROM clone_repository as apply_patches
WORKDIR /TrinityCore
COPY patch/00-G3D-System.h.diff .
COPY patch/01-G3D-FileSystem.cpp.diff .
RUN git apply *.diff

FROM apply_patches as build_servers
RUN mkdir /TrinityCore/build
WORKDIR /TrinityCore/build
RUN \
  --mount=type=cache,target=/TrinityCore/build \
  cmake \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/servers \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_LINKER=lld \
  -DSERVERS=ON \
  -DTOOLS=OFF \
  -DNOJEM=ON \
  ..
RUN \
  --mount=type=cache,target=/TrinityCore/build \
  cmake --build .
RUN exit 1

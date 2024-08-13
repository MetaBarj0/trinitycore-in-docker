ARG NAMESPACE
ARG BUILDERBASE_VERSION

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS authorize_github
ARG USER
ARG USER_HOME_DIR
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN mkdir -p .ssh
RUN ssh-keyscan github.com > .ssh/known_hosts

FROM authorize_github AS clone_repository
ARG REPOSITORY_URI
ARG REPOSITORY_REV
ARG REPOSITORY_SHA
ARG USER
ARG USER_GID
ARG USER_HOME_DIR
ARG USER_UID
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN \
  --mount=type=ssh,gid=${USER_GID},uid=${USER_UID} \
  git clone \
  --branch ${REPOSITORY_REV} --depth=1 \
  ${REPOSITORY_URI} TrinityCore
RUN cd TrinityCore && [ ! -z ${REPOSITORY_SHA} ] && git checkout ${REPOSITORY_SHA} && cd - || cd -

FROM clone_repository AS configure_build
ARG USER
ARG USER_GID
ARG USER_HOME_DIR
ARG USER_UID
USER ${USER}
RUN mkdir -p ${USER_HOME_DIR}/TrinityCore/build
WORKDIR ${USER_HOME_DIR}/TrinityCore/build
RUN \
  --mount=type=cache,target=${USER_HOME_DIR}/TrinityCore/build,uid=${USER_UID},gid=${USER_GID} \
  cmake \
  -G Ninja \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_INSTALL_PREFIX=/home/trinitycore/trinitycore \
  -DCONF_DIR=/home/trinitycore/trinitycore/etc \
  -DSCRIPTS=dynamic \
  -DWITHOUT_METRICS=ON \
  -DWITH_DETAILED_METRICS=OFF \
  -DWITH_DYNAMIC_LINKING=ON \
  ..

FROM configure_build AS cmake_build
ARG USER
ARG USER_GID
ARG USER_HOME_DIR
ARG USER_UID
USER ${USER}
WORKDIR ${USER_HOME_DIR}/TrinityCore/build
RUN \
  --mount=type=cache,target=${USER_HOME_DIR}/TrinityCore/build,uid=${USER_UID},gid=${USER_GID} \
  cmake --build .

FROM cmake_build AS cmake_install
ARG USER_GID
ARG USER_HOME_DIR
ARG USER_UID
USER root
WORKDIR ${USER_HOME_DIR}/TrinityCore/build
RUN \
  --mount=type=cache,target=${USER_HOME_DIR}/TrinityCore/build,uid=${USER_UID},gid=${USER_GID} \
  cmake --build . --target install
RUN chown -R trinitycore:trinitycore /home/trinitycore/trinitycore

FROM cmake_install AS install_packages
RUN \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  rsync

FROM install_packages
ARG BUILDER_VERSION
ARG GAMESERVERS_VERSION
ARG NAMESPACE
ARG COMPOSE_PROJECT_NAME
ARG USER
ARG USER_HOME_DIR
USER ${USER}
WORKDIR ${USER_HOME_DIR}
COPY \
  --chown=${USER}:${USER} \
  client_files.txt .
COPY --chown=${USER}:${USER} docker.d docker.d
COPY --chmod=755 scripts scripts
RUN mkdir -p trinitycore_configurations
COPY \
  --chown=${USER}:${USER} \
  worldserver.conf authserver.conf Makefile.env Makefile.maintainer.env \
  trinitycore_configurations/
RUN mkdir -p trinitycore_scripts
COPY \
  --chown=${USER}:${USER} \
  archive.sh trinitycore_scripts/
# TODO: remove wsl2_client_copy volume here, copy into container should be
#       sufficient
RUN mkdir -p data wsl2_client_copy TrinityCore
RUN touch wsl2_client_copy/.volume data/.volume TrinityCore/.volume
VOLUME ${USER_HOME_DIR}/data
VOLUME ${USER_HOME_DIR}/wsl2_client_copy
VOLUME ${USER_HOME_DIR}/TrinityCore
ENV BUILDER_IMAGE=${NAMESPACE}.builder:${BUILDER_VERSION}
ENV GAMESERVERS_IMAGE_TAG=${NAMESPACE}.gameservers:${GAMESERVERS_VERSION}
ENV SHELL=/bin/bash
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

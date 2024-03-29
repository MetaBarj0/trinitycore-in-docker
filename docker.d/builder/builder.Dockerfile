ARG NAMESPACE

FROM $NAMESPACE.builderbase as clone_repository
ARG REPOSITORY_URI
ARG REPOSITORY_REV
ARG REPOSITORY_SHA
USER trinitycore
WORKDIR /home/trinitycore
RUN git clone \
  --branch $REPOSITORY_REV --depth=1 \
  $REPOSITORY_URI TrinityCore
RUN cd TrinityCore && [ ! -z $REPOSITORY_SHA ] && git checkout $REPOSITORY_SHA && cd - || cd -

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

FROM install
ARG NAMESPACE
ARG COMPOSE_PROJECT_NAME
ARG USER
ARG USER_HOME_DIR
USER $USER
WORKDIR $USER_HOME_DIR
COPY --chown=$USER:$USER docker.d docker.d
COPY --chmod=755 scripts scripts
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
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

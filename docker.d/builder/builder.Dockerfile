ARG NAMESPACE

FROM $NAMESPACE.builderbase AS clone_repository
ARG REPOSITORY_URI
ARG REPOSITORY_REV
ARG REPOSITORY_SHA
# TODO: do not hardcode user!
USER trinitycore
WORKDIR /home/trinitycore
# EXPLAIN: in case of bad internet connections. Change the behavior of cloning
RUN \
  export GIT_TRACE_PACKET=1 \
  && export GIT_TRACE=1 \
  && export GIT_CURL_VERBOSE=1 \
  && git config --global http.version HTTP/1.1 \
  && git config --global http.postBuffer 524288000 \
  && git config --global http.maxRequestBuffer 524288000 \
  && git config --global http.lowSpeedLimit 0 \
  && git config --global http.lowSpeedTime 999999 \
  && git config --global core.compression 0
RUN git clone \
  --branch $REPOSITORY_REV --depth=1 \
  $REPOSITORY_URI TrinityCore
RUN cd TrinityCore && [ ! -z $REPOSITORY_SHA ] && git checkout $REPOSITORY_SHA && cd - || cd -

FROM clone_repository AS configure_build
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

FROM configure_build AS cmake_build
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build .

FROM cmake_build AS cmake_install
USER trinitycore
WORKDIR /home/trinitycore/TrinityCore/build
RUN \
  --mount=type=cache,target=/home/trinitycore/TrinityCore/build,uid=2000,gid=2000 \
  cmake --build . --target install

FROM clone_repository AS install
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

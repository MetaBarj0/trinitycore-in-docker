ARG NAMESPACE
ARG PLATFORM_TAG

FROM $NAMESPACE.builderbase$PLATFORM_TAG AS neovim_build
ARG USER
ARG USER_HOME_DIR
ARG IDE_NEOVIM_REV
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  make gettext
USER $USER
RUN mkdir $USER_HOME_DIR/nvim-build
WORKDIR $USER_HOME_DIR/nvim-build
RUN git clone --branch $IDE_NEOVIM_REV --depth=1 \
 https://github.com/neovim/neovim
WORKDIR $USER_HOME_DIR/nvim-build/neovim
RUN make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$USER_HOME_DIR/nvim
RUN make install

FROM $NAMESPACE.builderbase$PLATFORM_TAG AS neovim_install
ARG USER_HOME_DIR
COPY --from=neovim_build $USER_HOME_DIR/nvim $USER_HOME_DIR/.nvim
ENV NVIM_INSTALL_DIR $USER_HOME_DIR/.nvim/
ENV PATH=${PATH}:${NVIM_INSTALL_DIR}/bin

FROM neovim_install AS deno_install
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  unzip
USER $USER
WORKDIR $USER_HOME_DIR
RUN curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=$USER_HOME_DIR/.deno sh
ENV DENO_INSTALL_DIR $USER_HOME_DIR/.deno
ENV PATH ${PATH}:${DENO_INSTALL_DIR}/bin

FROM deno_install AS nodejs_extract
ARG NODEJS_VER
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  wget xz-utils
USER $USER
WORKDIR $USER_HOME_DIR
RUN wget https://nodejs.org/dist/$NODEJS_VER/node-$NODEJS_VER-linux-x64.tar.xz
RUN tar -xf node-$NODEJS_VER-linux-x64.tar.xz

FROM deno_install AS nodejs_install
ARG NODEJS_VER
ARG USER_HOME_DIR
RUN mkdir $USER_HOME_DIR/.nodejs
WORKDIR $USER_HOME_DIR/.nodejs
COPY --from=nodejs_extract $USER_HOME_DIR/node-$NODEJS_VER-linux-x64/ .
ENV NODEJS_INSTALL_DIR $USER_HOME_DIR/.nodejs
ENV PATH ${PATH}:${NODEJS_INSTALL_DIR}/bin

FROM nodejs_install AS uctags_build
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  pkg-config make
USER $USER
WORKDIR $USER_HOME_DIR
RUN mkdir uctags-build
WORKDIR $USER_HOME_DIR/uctags-build
RUN git clone --branch master --depth=1 \
  https://github.com/universal-ctags/ctags.git
WORKDIR $USER_HOME_DIR/uctags-build/ctags
RUN ./autogen.sh
RUN ./configure --prefix=$USER_HOME_DIR/.ctags
RUN make -j $(nproc)
RUN make install

FROM nodejs_install AS uctags_install
ARG USER_HOME_DIR
COPY --from=uctags_build $USER_HOME_DIR/.ctags/ $USER_HOME_DIR/.ctags/
ENV CTAGS_INSTALL_DIR $USER_HOME_DIR/.ctags
ENV PATH ${PATH}:${CTAGS_INSTALL_DIR}/bin

FROM uctags_install AS environments_clone
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
RUN git clone --branch master --depth 1 \
  https://github.com/MetaBarj0/environments.git

FROM uctags_install AS environments_configuration
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
RUN mkdir .bashd
RUN mkdir -p ./.init/nvim
RUN mkdir -p ./.init/tmux
RUN mkdir -p ./.local/share/nvim/site/autoload
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/git/USER_HOME_DIR/.gitconfig .
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/bash/USER_HOME_DIR/.bashd/.* ./.bashd/
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/bash/USER_HOME_DIR/.bashrc .
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/nodejs/USER_HOME_DIR/.npmrc .
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/neovim/USER_HOME_DIR/.init/nvim/init.vim ./.init/nvim/
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/neovim/USER_HOME_DIR/.local/share/nvim/site/autoload/plug.vim ./.local/share/nvim/site/autoload/plug.vim
COPY --from=environments_clone \
  $USER_HOME_DIR/environments/common/tmux/USER_HOME_DIR/.init/tmux/tmux.conf ./.init/tmux/

FROM environments_configuration AS package_install
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  tmux python3-neovim locales clangd-16
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-16 100
USER $USER

FROM package_install AS nodejs_global_packages_install
RUN npm install -g neovim npm-check-updates

FROM nodejs_global_packages_install AS install_locales
USER root
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

FROM install_locales
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
ARG USER
ARG USER_HOME_DIR
USER $USER
WORKDIR $USER_HOME_DIR
COPY --chmod=755 scripts scripts
VOLUME $USER_HOME_DIR/client_data
VOLUME $USER_HOME_DIR/ide_storage
VOLUME $USER_HOME_DIR/.npm-prefix
VOLUME $USER_HOME_DIR/.npm-cache
VOLUME $USER_HOME_DIR/.local
LABEL project=$COMPOSE_PROJECT_NAME
LABEL namespace=$NAMESPACE

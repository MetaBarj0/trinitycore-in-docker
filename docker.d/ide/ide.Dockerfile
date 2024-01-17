ARG NAMESPACE
ARG PLATFORM_TAG

FROM $NAMESPACE.builderbase$PLATFORM_TAG as neovim_build
ARG IDE_NEOVIM_REV
# TODO: use the real user instead of root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  make gettext
# TODO: fix path
RUN mkdir /opt/nvim-build
WORKDIR /opt/nvim-build
RUN git clone --branch $IDE_NEOVIM_REV --depth=1 \
 https://github.com/neovim/neovim
WORKDIR /opt/nvim-build/neovim
RUN make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/opt/nvim
RUN make install

FROM $NAMESPACE.builderbase$PLATFORM_TAG as neovim_install
COPY --from=neovim_build /opt/nvim /opt/nvim/
ENV NVIM_INSTALL_DIR /opt/nvim/
ENV PATH=${PATH}:${NVIM_INSTALL_DIR}/bin

FROM neovim_install as deno_install
ARG USER_HOME_DIR
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  unzip
WORKDIR $USER_HOME_DIR
RUN curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=$USER_HOME_DIR/.deno sh
ENV DENO_INSTALL_DIR $USER_HOME_DIR/.deno
ENV PATH ${PATH}:${DENO_INSTALL_DIR}/bin

FROM deno_install as nodejs_extract
ARG NODEJS_VER
ARG USER_HOME_DIR
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  wget xz-utils
WORKDIR $USER_HOME_DIR
RUN wget https://nodejs.org/dist/$NODEJS_VER/node-$NODEJS_VER-linux-x64.tar.xz
RUN tar -xf node-$NODEJS_VER-linux-x64.tar.xz

FROM deno_install as nodejs_global_packages_install
ARG NODEJS_VER
ARG USER_HOME_DIR
RUN mkdir $USER_HOME_DIR/.nodejs
WORKDIR $USER_HOME_DIR/.nodejs
COPY --from=nodejs_extract $USER_HOME_DIR/node-$NODEJS_VER-linux-x64/ .
ENV NODEJS_INSTALL_DIR $USER_HOME_DIR/.nodejs
ENV PATH ${PATH}:${NODEJS_INSTALL_DIR}/bin
RUN npm install -g neovim npm-check-updates

FROM nodejs_global_packages_install as uctags_build
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  pkg-config make
RUN mkdir ./uctags-build
WORKDIR $USER_HOME_DIR/uctags-build
RUN git clone --branch master --depth=1 \
  https://github.com/universal-ctags/ctags.git
WORKDIR $USER_HOME_DIR/uctags-build/ctags
RUN ./autogen.sh
RUN ./configure --prefix=$USER_HOME_DIR/.ctags
RUN make -j $(nproc)
RUN make install

FROM nodejs_global_packages_install as uctags_install
ARG USER_HOME_DIR
COPY --from=uctags_build $USER_HOME_DIR/.ctags/ $USER_HOME_DIR/.ctags/
ENV CTAGS_INSTALL_DIR $USER_HOME_DIR/.ctags
ENV PATH ${PATH}:${CTAGS_INSTALL_DIR}/bin

FROM uctags_install as libevent_build
ARG USER_HOME_DIR
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libtool pkg-config make
WORKDIR $USER_HOME_DIR
RUN mkdir -p ./libevent-build
WORKDIR $USER_HOME_DIR/libevent-build
RUN git clone --branch master --depth=1 \
  https://github.com/libevent/libevent.git
WORKDIR $USER_HOME_DIR/libevent-build/libevent
RUN ./autogen.sh
RUN ./configure --prefix=/home/dev/.libevent
RUN make -j $(nproc)
RUN make install

# TODO: fix here regarding user home dir
FROM uctags_install as libevent_install
COPY --from=libevent_build /home/dev/.libevent/ /usr/local/

FROM libevent_install as tmux_build
ARG USER_HOME_DIR
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  libncurses-dev make pkg-config bison
WORKDIR $USER_HOME_DIR
RUN mkdir -p ./tmux-build
WORKDIR $USER_HOME_DIR/tmux-build
RUN git clone --branch master --depth=1 \
  https://github.com/tmux/tmux.git
WORKDIR $USER_HOME_DIR/tmux-build/tmux
RUN ./autogen.sh
RUN ./configure --prefix=$USER_HOME_DIR/.tmux
RUN make -j $(nproc)
RUN make install

FROM libevent_install as tmux_install
ARG USER
ARG USER_HOME_DIR
COPY --from=tmux_build --chown=$USER:$USER \
  $USER_HOME_DIR/.tmux/ $USER_HOME_DIR/.tmux
ENV TMUX_INSTALL_DIR $USER_HOME_DIR/.tmux
ENV PATH ${PATH}:${TMUX_INSTALL_DIR}/bin

FROM tmux_install as environments_clone
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
RUN git clone --branch master --depth 1 \
  https://github.com/MetaBarj0/environments.git

FROM tmux_install as environments_configuration
ARG USER
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
RUN mkdir .bashd && chown $USER:$USER .bashd
RUN mkdir -p ./.init/nvim
RUN mkdir -p ./.init/tmux
RUN chown -R $USER:$USER .init
RUN mkdir -p ./.local/share/nvim/site/autoload
RUN chown -R $USER:$USER .local
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/git/USER_HOME_DIR/.gitconfig .
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/bash/USER_HOME_DIR/.bashd/.* ./.bashd/
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/bash/USER_HOME_DIR/.bashrc .
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/nodejs/USER_HOME_DIR/.npmrc .
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/neovim/USER_HOME_DIR/.init/nvim/init.vim ./.init/nvim/
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/neovim/USER_HOME_DIR/.local/share/nvim/site/autoload/plug.vim ./.local/share/nvim/site/autoload/plug.vim
COPY --from=environments_clone \
  --chown=$USER:$USER \
  $USER_HOME_DIR/environments/common/tmux/USER_HOME_DIR/.init/tmux/tmux.conf ./.init/tmux/

FROM environments_configuration
ARG USER
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
COPY \
  --chown=$USER:$USER \
  --chmod=755 \
  scripts scripts
RUN mkdir -p $USER_HOME_DIR/client_data
RUN chown -R $USER:$USER $USER_HOME_DIR/client_data
VOLUME $USER_HOME_DIR/client_data
RUN mkdir -p $USER_HOME_DIR/ide_storage
RUN chown -R $USER:$USER $USER_HOME_DIR/ide_storage
VOLUME $USER_HOME_DIR/ide_storage
RUN mkdir -p $USER_HOME_DIR/.npm-prefix
RUN chown -R $USER:$USER $USER_HOME_DIR/.npm-prefix
VOLUME $USER_HOME_DIR/.npm-prefix
RUN mkdir -p $USER_HOME_DIR/.npm-cache
RUN chown -R $USER:$USER $USER_HOME_DIR/.npm-cache
VOLUME $USER_HOME_DIR/.npm-cache
RUN mkdir -p $USER_HOME_DIR/.local
RUN chown -R $USER:$USER $USER_HOME_DIR/.local
VOLUME $USER_HOME_DIR/.local
USER $USER

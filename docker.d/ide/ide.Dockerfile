ARG NAMESPACE
ARG BUILDERBASE_VERSION

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS fetch_neovim
ARG USER
ARG USER_HOME_DIR
ARG NEOVIM_REV
USER ${USER}
RUN mkdir ${USER_HOME_DIR}/nvim-build
WORKDIR ${USER_HOME_DIR}/nvim-build
RUN git clone --branch ${NEOVIM_REV} --depth=1 \
 https://github.com/neovim/neovim

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS fetch_nodejs
ARG NODEJS_VER
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  wget curl jq
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN \
  [ $(arch) = 'aarch64' ] && nodejs_arch='arm64' \
  ; [ $(arch) = 'x86_64' ] && nodejs_arch='x64' \
  ; [ "${NODEJS_VER}" != 'latest' ] \
  && wget https://nodejs.org/dist/${NODEJS_VER}/node-${NODEJS_VER}-linux-${nodejs_arch}.tar.xz \
  || ( \
       query='sort_by(.tag_name) | reverse | .[0].tag_name' \
       && version=$(curl -s https://api.github.com/repos/nodejs/node/releases \
          | jq "${query}" \
          | sed 's/"//g') \
          && wget https://nodejs.org/dist/${version}/node-${version}-linux-${nodejs_arch}.tar.xz \
     )

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS fetch_uctags
ARG USER
ARG USER_HOME_DIR
USER ${USER}
RUN mkdir ${USER_HOME_DIR}/uctags-build
WORKDIR ${USER_HOME_DIR}/uctags-build
RUN git clone --branch master --depth=1 \
  https://github.com/universal-ctags/ctags.git

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS fetch_environments
ARG USER
ARG USER_HOME_DIR
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN git clone --branch master --depth 1 \
  https://github.com/MetaBarj0/environments.git

FROM fetch_neovim AS build_neovim
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  make gettext
WORKDIR ${USER_HOME_DIR}/nvim-build/neovim
RUN make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${USER_HOME_DIR}/nvim
RUN make install

FROM fetch_uctags AS build_uctags
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  pkg-config make
WORKDIR ${USER_HOME_DIR}/uctags-build/ctags
RUN ./autogen.sh
RUN ./configure --prefix=${USER_HOME_DIR}/.ctags
RUN make -j $(nproc)
RUN make install

FROM fetch_nodejs AS extract_nodejs
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  xz-utils
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN tar x -f node-*-linux-*.tar.xz

FROM ${NAMESPACE}.builderbase:${BUILDERBASE_VERSION} AS install_nodejs
ARG USER_HOME_DIR
ARG USER
USER ${USER}
RUN mkdir ${USER_HOME_DIR}/.nodejs
WORKDIR ${USER_HOME_DIR}/.nodejs
COPY --from=extract_nodejs ${USER_HOME_DIR}/node-*-linux-*/ .
ENV NODEJS_INSTALL_DIR=${USER_HOME_DIR}/.nodejs
ENV PATH=${PATH}:${NODEJS_INSTALL_DIR}/bin

FROM install_nodejs AS install_deno
ARG USER
ARG USER_HOME_DIR
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  unzip
USER ${USER}
WORKDIR ${USER_HOME_DIR}
RUN curl -fsSL https://deno.land/x/install/install.sh | DENO_INSTALL=${USER_HOME_DIR}/.deno sh
ENV DENO_INSTALL_DIR=${USER_HOME_DIR}/.deno
ENV PATH=${PATH}:${DENO_INSTALL_DIR}/bin

FROM install_deno AS install_neovim
ARG USER_HOME_DIR
COPY --from=build_neovim ${USER_HOME_DIR}/nvim ${USER_HOME_DIR}/.nvim
ENV NVIM_INSTALL_DIR=${USER_HOME_DIR}/.nvim/
ENV PATH=${PATH}:${NVIM_INSTALL_DIR}/bin

FROM install_neovim AS install_uctags
ARG USER_HOME_DIR
COPY --from=build_uctags ${USER_HOME_DIR}/.ctags/ ${USER_HOME_DIR}/.ctags/
ENV CTAGS_INSTALL_DIR=${USER_HOME_DIR}/.ctags
ENV PATH=${PATH}:${CTAGS_INSTALL_DIR}/bin

FROM install_uctags AS install_environment
ARG USER_HOME_DIR
WORKDIR ${USER_HOME_DIR}
RUN mkdir .bashd
RUN mkdir -p ./.init/nvim
RUN mkdir -p ./.init/tmux
RUN mkdir -p ./.local/share/nvim/site/autoload
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/git/USER_HOME_DIR/.gitconfig .
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/bash/USER_HOME_DIR/.bashd/.* ./.bashd/
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/bash/USER_HOME_DIR/.bashrc .
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/nodejs/USER_HOME_DIR/.npmrc .
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/neovim/USER_HOME_DIR/.init/nvim/init.vim ./.init/nvim/
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/neovim/USER_HOME_DIR/.local/share/nvim/site/autoload/plug.vim ./.local/share/nvim/site/autoload/plug.vim
COPY --from=fetch_environments \
  ${USER_HOME_DIR}/environments/common/tmux/USER_HOME_DIR/.init/tmux/tmux.conf ./.init/tmux/

FROM install_environment AS install_nodejs_global_packages
RUN npm install -g neovim npm-check-updates

FROM install_nodejs_global_packages AS install_packages
ARG USER
USER root
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  tmux python3-neovim locales clangd-16 sudo tig man-db less make btop \
  python3.11-venv cmake-curses-gui lldb-16 clang-format-16 telnet p7zip jq wget
RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-16 100
RUN update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-16 100
RUN update-alternatives --install /usr/bin/lldb-vscode lldb-vscode /usr/bin/lldb-vscode-16 100
RUN update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-16 100
RUN echo ${USER}' ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ide
USER ${USER}

FROM install_packages AS install_locales
USER root
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

FROM install_locales
ARG CLIENT_PATH
ARG COMPOSE_PROJECT_NAME
ARG NAMESPACE
ARG USER
ARG USER_HOME_DIR
USER ${USER}
WORKDIR ${USER_HOME_DIR}
COPY --chmod=755 scripts scripts
RUN mkdir -p trinitycore_configurations
COPY \
  --chown=${USER}:${USER} \
  --chmod=440 \
  worldserver.conf authserver.conf \
  trinitycore_configurations/
RUN mkdir -p \
  ${USER_HOME_DIR}/client_data/ \
  ${USER_HOME_DIR}/ide_storage/ \
  ${USER_HOME_DIR}/.npm-prefix/ \
  ${USER_HOME_DIR}/.npm-cache/ \
  ${USER_HOME_DIR}/.init/ \
  ${USER_HOME_DIR}/.local/
VOLUME ${USER_HOME_DIR}/client_data
VOLUME ${USER_HOME_DIR}/ide_storage
VOLUME ${USER_HOME_DIR}/.npm-prefix
VOLUME ${USER_HOME_DIR}/.npm-cache
VOLUME ${USER_HOME_DIR}/.init
VOLUME ${USER_HOME_DIR}/.local
VOLUME ${CLIENT_PATH}
RUN touch \
  ${USER_HOME_DIR}/client_data/.volume \
  ${USER_HOME_DIR}/ide_storage/.volume \
  ${USER_HOME_DIR}/.npm-prefix/.volume \
  ${USER_HOME_DIR}/.npm-cache/.volume \
  ${USER_HOME_DIR}/.init/.volume \
  ${USER_HOME_DIR}/.local/.volume
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV NVIM_LLDB_VSCODE_PATH=/usr/bin/lldb-vscode
ENV PATH=${PATH}:${USER_HOME_DIR}/scripts
ENV SHELL=/bin/bash
ENV TERM=xterm-256color
ENV USER_HOME_DIR=${USER_HOME_DIR}
LABEL project=${COMPOSE_PROJECT_NAME}
LABEL namespace=${NAMESPACE}

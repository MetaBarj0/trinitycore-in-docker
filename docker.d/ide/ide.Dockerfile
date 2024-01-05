ARG NAMESPACE

FROM $NAMESPACE.builderbase as neovim_build
ARG IDE_NEOVIM_REV
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update
RUN \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get install -y --no-install-recommends \
  make gettext
RUN mkdir /opt/nvim-build
WORKDIR /opt/nvim-build
RUN git clone --branch $IDE_NEOVIM_REV --depth=1 \
 https://github.com/neovim/neovim
WORKDIR /opt/nvim-build/neovim
RUN make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=/opt/nvim
RUN make install

FROM $NAMESPACE.builderbase as neovim_install
COPY --from=neovim_build /opt/nvim /opt/nvim/
ENV NVIM_INSTALL_DIR /opt/nvim/
ENV PATH=${PATH}:${NVIM_INSTALL_DIR}/bin

FROM neovim_install
ARG USER
ARG USER_HOME_DIR
WORKDIR $USER_HOME_DIR
COPY \
  --chown=$USER:$USER \
  --chmod=755 \
  scripts scripts
RUN mkdir $USER_HOME_DIR/client_data
RUN chown -R $USER:$USER $USER_HOME_DIR/client_data
VOLUME $USER_HOME_DIR/client_data
RUN mkdir $USER_HOME_DIR/ide_storage
RUN chown -R $USER:$USER $USER_HOME_DIR/ide_storage
VOLUME $USER_HOME_DIR/ide_storage
USER $USER

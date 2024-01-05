ARG NAMESPACE

FROM $NAMESPACE.builderbase
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

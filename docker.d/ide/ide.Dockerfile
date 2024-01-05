ARG NAMESPACE

FROM $NAMESPACE.builderbase
USER trinitycore
WORKDIR /home/trinitycore
COPY \
  --chown=trinitycore:trinitycore \
  --chmod=755 \
  scripts scripts

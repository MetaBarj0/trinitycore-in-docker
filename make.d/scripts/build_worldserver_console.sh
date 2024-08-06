. ./make.d/scripts/archive.sh

archive_files_to \
  Makefile.env \
  Makefile.maintainer.env \
  ./docker.d/worldserver_console/configuration_files.tar

docker build \
  --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
  --build-arg NAMESPACE=${NAMESPACE} \
  -t ${NAMESPACE}.worldserver_console:${WORLDSERVER_CONSOLE_VERSION} \
  -f docker.d/worldserver_console/worldserver_console.Dockerfile \
  docker.d/worldserver_console

rm -f ./docker.d/worldserver_console/configuration_files.tar

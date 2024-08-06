. ./make.d/scripts/archive.sh

archive_files_to \
  Makefile.env \
  Makefile.maintainer.env \
  ./docker.d/worldserver_remote_access/configuration_files.tar

docker build \
  --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
  --build-arg NAMESPACE=${NAMESPACE} \
  -t ${NAMESPACE}.worldserver_remote_access:${WORLDSERVER_REMOTE_ACCESS_VERSION} \
  -f docker.d/worldserver_remote_access/worldserver_remote_access.Dockerfile \
  docker.d/worldserver_remote_access

rm -f ./docker.d/worldserver_remote_access/configuration_files.tar

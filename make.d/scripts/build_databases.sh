. ./make.d/scripts/archive.sh

archive_files_to \
  Makefile.env \
  Makefile.maintainer.env \
  ./docker.d/databases/configuration_files.tar

docker build \
  --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
  --build-arg NAMESPACE=${NAMESPACE} \
  -f docker.d/databases/databases.Dockerfile \
  -t ${NAMESPACE}.databases:${DATABASES_VERSION} \
  docker.d/databases

rm -f ./docker.d/databases/configuration_files.tar

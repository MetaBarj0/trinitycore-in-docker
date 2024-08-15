. ./make.d/scripts/archive.sh
. ./make.d/scripts/copy_configuration_files_in_build_context.sh

main() {
  archive_files_to \
    Makefile.env \
    Makefile.maintainer.env \
    ./docker.d/databases/configuration_files.tar

  copy_create_mysql_in_build_context \
    'docker.d/databases' \

  docker build \
    --build-arg COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME} \
    --build-arg NAMESPACE=${NAMESPACE} \
    -f docker.d/databases/databases.Dockerfile \
    -t ${NAMESPACE}.databases:${DATABASES_VERSION} \
    docker.d/databases
}

main

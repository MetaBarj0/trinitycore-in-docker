. ./make.d/scripts/archive.sh

archive_files_to \
  Makefile.env \
  Makefile.maintainer.env \
  ./docker.d/databases/configuration_files.tar

docker compose -f docker.d/docker-compose.yml build databases

rm -f ./docker.d/databases/configuration_files.tar

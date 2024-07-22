. ./make.d/scripts/archive.sh

archive_files_to \
  Makefile.env \
  Makefile.maintainer.env \
  ./docker.d/worldserver_console/configuration_files.tar

docker compose -f docker.d/docker-compose.yml build worldserver_console

rm -f ./docker.d/worldserver_console/configuration_files.tar

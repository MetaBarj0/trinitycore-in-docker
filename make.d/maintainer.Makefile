ps:
	@docker compose ps

config:
	@docker compose config

_build_debian_upgraded:
	@docker build \
		-f docker.d/_common/debian:12.2-slim-upgraded.Dockerfile \
		-t debian:12.2-slim-upgraded \
		docker.d/_common

build_servers_and_tools_builder: _build_debian_upgraded
	@cp "${WORLDSERVER_CONF_PATH}" docker.d/servers_and_tools_builder/
	@cp "${AUTHSERVER_CONF_PATH}" docker.d/servers_and_tools_builder/
	@docker compose build servers_and_tools_builder \
		--build-arg DOCKER_GID=$$(getent group docker | cut -d : -f 3) \
		--build-arg DOCKER_UID=$$(id -u)

debug_build_databases:
	@BUILDX_EXPERIMENTAL=1 \
		docker buildx debug build \
		-f docker.d/databases/databases.Dockerfile \
		docker.d/databases

debug_build_servers_and_tools_builder:
	@BUILDX_EXPERIMENTAL=1 \
		docker buildx debug build \
		--build-arg DOCKER_GID=$$(getent group docker | cut -d : -f 3) \
		--build-arg DOCKER_UID=$$(id -u) \
		-f docker.d/servers_and_tools_builder/servers_and_tools_builder.Dockerfile \
		docker.d/servers_and_tools_builder


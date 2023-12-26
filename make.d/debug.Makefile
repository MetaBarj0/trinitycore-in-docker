config:
	@docker compose config

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


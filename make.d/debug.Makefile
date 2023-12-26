config:
	@docker compose config

debug_build_databases:
	@BUILDX_EXPERIMENTAL=1 \
		docker buildx debug build \
		-f docker.d/databases/databases.Dockerfile \
		docker.d/databases


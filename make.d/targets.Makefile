include $(MAKEFILE_DIR)/Makefile.maintainer.env
export

include $(MAKEFILE_DIR)/make.d/macros.Makefile

ps:
	@docker compose ps

config:
	@docker compose config

build_debian_upgraded:
	$(call build_debian_upgraded)

build_servers_and_tools_builder: build_debian_upgraded
	$(call copy_servers_conf_in_build_context)
	$(call build_servers_and_tools_builder)

debug_build_databases:
	@BUILDX_EXPERIMENTAL=1 \
		docker buildx debug build \
		-f docker.d/databases/databases.Dockerfile \
		docker.d/databases

debug_build_servers_and_tools_builder:
	$(call copy_servers_conf_in_build_context)
	$(call debug_build_servers_and_tools_builder)


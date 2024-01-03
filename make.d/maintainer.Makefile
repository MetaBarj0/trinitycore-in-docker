include $(MAKEFILE_DIR)/Makefile.maintainer.env
export

include $(MAKEFILE_DIR)/make.d/macros.Makefile

ps:
	@docker compose ps

config:
	@docker compose config

# TODO: weird target name, xform this to macro then scripts...
_build_debian_upgraded:
	@docker build \
		-f docker.d/_common/debian-12.2-slim-upgraded.Dockerfile \
		-t debian:12.2-slim-upgraded \
		docker.d/_common

build_servers_and_tools_builder: _build_debian_upgraded
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


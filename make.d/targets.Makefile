include $(MAKEFILE_DIR)/Makefile.maintainer.env
export

include $(MAKEFILE_DIR)/make.d/macros.Makefile

ps:
	@docker compose ps

config:
	@docker compose config

build_debian_upgraded:
	$(call build_debian_upgraded)

build_server_base:
	$(call build_server_base)

build_builder_base:
	$(call build_builder_base)

build_builder: build_debian_upgraded build_server_base build_builder_base
	$(call copy_servers_conf_in_build_context)
	$(call build_builder)

debug_build_databases:
	@BUILDX_EXPERIMENTAL=1 \
		docker buildx debug build \
		-f docker.d/databases/databases.Dockerfile \
		docker.d/databases

debug_build_builder:
	$(call copy_servers_conf_in_build_context)
	$(call debug_build_builder)

Makefile.env:
	$(call create_file_from_template,Makefile.env,Makefile.env.dist)

Makefile.maintainer.env:
	$(call create_file_from_template,Makefile.maintainer.env,Makefile.maintainer.env.dist)

build_ide: TARGET_PLATFORM=linux/amd64
build_ide: build_debian_upgraded build_server_base build_builder_base
	$(call build_ide)

up_ide:
	$(call up_ide)

down_ide:
	$(call down_ide)

shell_ide:
	$(call shell_ide)

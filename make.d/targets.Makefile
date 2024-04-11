include $(MAKEFILE_DIR)/Makefile.maintainer.env
export

include $(MAKEFILE_DIR)/make.d/macros.Makefile

ps:
	@docker compose ps

config:
	@docker compose config

build_databases:
	@docker compose build databases

build_servers_and_tools: build_builder
	$(call build_servers_and_tools)

build_worldserver_console:
	@docker compose build worldserver_console

build_debian_upgraded:
	$(call build_debian_upgraded)

build_server_base:
	$(call build_server_base)

build_builder_base:
	$(call build_builder_base)

build_builder: build_debian_upgraded build_server_base build_builder_base
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

ide: TARGET_PLATFORM=linux/amd64
ide: build_ide up_ide shell_ide

build_ide: TARGET_PLATFORM=linux/amd64
build_ide: build_debian_upgraded build_server_base build_builder_base
	$(call build_ide)

up_ide:
	$(call up_ide)

down_ide:
	@docker compose down ide

shell_ide:
	$(call shell_ide)

clean: down
	$(call clean)

rebuild: clean build

nuke: remove_volumes=true
nuke: clean

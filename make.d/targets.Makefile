include $(MAKEFILE_DIR)/Makefile.maintainer.env

export

include $(MAKEFILE_DIR)/make.d/macros.Makefile

ps:
	@docker compose -f docker.d/docker-compose.yml ps

config: compose_args=
config:
	@docker compose -f docker.d/docker-compose.yml $(compose_args) config

build_databases: ensure_prepared
	$(call build_databases)

build_servers_and_tools: build_builder
	$(call build_servers_and_tools)

build_worldserver_remote_access:
	$(call build_worldserver_remote_access)

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

Makefile.env: ENV_FILE=$@
Makefile.env: ENV_FILE_TEMPLATE=$@.dist
Makefile.env:
	$(call create_file_from_template)

Makefile.maintainer.env: ENV_FILE=$@
Makefile.maintainer.env: ENV_FILE_TEMPLATE=$@.dist
Makefile.maintainer.env:
	$(call create_file_from_template)

ide: build_ide up_ide shell_ide

build_ide: ensure_prepared build_debian_upgraded build_server_base build_builder_base
	$(call build_ide)

up_ide: service = ide
up_ide:
	$(call up_service_or_all)

down_ide:
	@docker compose -f docker.d/docker-compose.yml down ide

nuke_ide:
	@docker compose -f docker.d/docker-compose.yml down --volumes ide

shell_ide:
	$(call shell_ide)

clean: down
	$(call clean)

rebuild: clean build

nuke: remove_volumes=true
nuke: clean

logs:
	@docker compose -f docker.d/docker-compose.yml logs --follow

ensure_prepared:
	$(call ensure_prepared)

extract_conf:
	$(call extract_conf)

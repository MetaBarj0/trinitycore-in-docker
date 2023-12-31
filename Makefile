# Weird trick to 'force' make to use the shell it has been invoked with.
# If not applied, build fail on Windows, WSL2
SHELL := $(shell echo $$SHELL)
MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include make.d/macros.Makefile
include make.d/targets.Makefile
include Makefile.env

export

help: maintainer_mode = 0
help:
	$(call print_usage)

prepare: Makefile.env Makefile.maintainer.env
	$(call fetch_server_configuration_files)
	$(call print_post_prepare_message)

build_databases:
	@docker compose build databases

build_servers_and_tools: build_builder
	$(call build_servers_and_tools)

build_worldserver_console:
	@docker compose build worldserver_console

build: build_databases build_servers_and_tools build_worldserver_console

up:
	@docker compose up --detach

down:
	@docker compose down

exec: cmd = 'server info'
exec:
	$(call check_cmd,$(cmd))
	@docker exec $(COMPOSE_PROJECT_NAME)-worldserver_console-1 \
		sh -c "execute_console_command.sh '$(cmd)'"

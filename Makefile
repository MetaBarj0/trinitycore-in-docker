# Weird trick to 'force' make to use the shell it has been invoked with.
SHELL := $(shell echo $$SHELL)

MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include make.d/macros.Makefile

include Makefile.env
export

help: maintainer_mode = 0
help:
	$(call print_usage,$(maintainer_mode))

build_databases:
	@docker compose build databases

build_servers_and_tools: build_servers_and_tools_builder
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

include make.d/maintainer.Makefile

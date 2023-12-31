# TODO: hide implementation details

# Weird trick to 'force' make to use the shell it has been invoked with.
SHELL := $(shell echo $$SHELL)

MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include $(MAKEFILE_DIR)/make.d/macros.Makefile

include $(MAKEFILE_DIR)/Makefile.env
export

maintainer_mode := 0

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

cmd :=

COMPOSE_PROJECT_NAME := trinitycore-in-docker

exec:
	$(call check_cmd,$(cmd))
	@docker exec $(COMPOSE_PROJECT_NAME)-worldserver_console-1 \
		sh -c "execute_console_command.sh '$(cmd)'"

include $(MAKEFILE_DIR)/make.d/maintainer.Makefile

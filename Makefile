SHELL := env bash

MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include $(MAKEFILE_DIR)/make.d/env_file/Makefile.env
export

maintainer_mode := 0

define print_usage
  @. $(MAKEFILE_DIR)/make.d/scripts/print_usage.sh $(maintainer_mode)
endef

help:
	$(call print_usage,$(maintainer_mode))

build_databases:
	@docker compose build databases

build_servers: build_servers_and_tools_builder
	@docker compose up servers_and_tools_builder
	@docker compose down servers_and_tools_builder

build_worldserver_console:
	@docker compose build worldserver_console

build: build_databases build_servers build_worldserver_console

up:
	@docker compose up --detach

down:
	@docker compose down

include $(MAKEFILE_DIR)/make.d/maintainer.Makefile

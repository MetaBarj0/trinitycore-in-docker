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

build_servers_and_tools_builder:
	@docker compose build servers_and_tools_builder \
		--build-arg DOCKER_GID=$$(getent group docker | cut -d : -f 3) \
		--build-arg DOCKER_UID=$$(id -u)

build_servers: build_servers_and_tools_builder
	@docker compose up servers_and_tools_builder
	@docker compose down servers_and_tools_builder

build:
	@echo Not Implemented Yet

include $(MAKEFILE_DIR)/make.d/debug.Makefile

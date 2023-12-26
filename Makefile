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

build_servers:
	@docker compose build servers

build:
	@docker compose build

include $(MAKEFILE_DIR)/make.d/debug.Makefile

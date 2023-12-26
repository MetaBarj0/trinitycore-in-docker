SHELL := env bash

MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include $(MAKEFILE_DIR)/make.d/env_file/Makefile.env
export


define print_usage
  @. $(MAKEFILE_DIR)/make.d/scripts/print_usage.sh
endef

help:
	$(call print_usage)

build_databases:
	@docker compose build databases

build_authserver:
	@docker compose build authserver

build_worldserver:
	@docker compose build worldserver

build:
	@docker compose build

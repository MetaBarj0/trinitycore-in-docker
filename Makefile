MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

include make.d/macros.Makefile
include make.d/targets.Makefile
include Makefile.env

export

help: maintainer_mode = 0
help:
	$(call help)

prepare: Makefile.env Makefile.maintainer.env
	$(call prepare)

# TODO: harden even more ensure_prepared
build: build_databases build_servers_and_tools build_worldserver_console

up:
	@docker compose -f docker.d/docker-compose.yml up --detach

down:
	$(call down)

exec: cmd = 'server info'
exec:
	$(call exec,$(cmd))

init: maintainer_mode = 0
init:
	$(call init)

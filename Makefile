# EXPLAIN: Weird trick to 'force' make to use the shell it has been invoked
# with. If not applied, build fail on Windows, WSL2
SHELL := $(shell echo $$SHELL)
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

build: ensure_prepared build_databases build_servers_and_tools build_worldserver_console

up:
	@docker compose up --detach

down: down_ide
	$(call down)

exec: cmd = 'server info'
exec:
	$(call exec,$(cmd))

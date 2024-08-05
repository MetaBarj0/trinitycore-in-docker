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

build: build_databases build_servers_and_tools build_worldserver_console

up: service = 
up:
	$(call up_service_or_all)

down:
	$(call down)

exec: cmd = 'server info'
exec:
	$(call exec,$(cmd))

init: maintainer_mode = 0
init:
	$(call init)

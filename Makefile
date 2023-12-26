SHELL := env bash

MAKEFILE_DIR := $(shell dirname $(MAKEFILE_LIST))

define fetch_usage
  @. $(MAKEFILE_DIR)/make.d/fetch_usage.sh
endef

help:
	$(call fetch_usage)

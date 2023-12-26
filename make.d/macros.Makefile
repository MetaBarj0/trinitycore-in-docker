define print_usage
  @. $(MAKEFILE_DIR)/make.d/scripts/print_usage.sh $(maintainer_mode)
endef

define check_cmd
  @. $(MAKEFILE_DIR)/make.d/scripts/check_cmd.sh $(cmd)
endef


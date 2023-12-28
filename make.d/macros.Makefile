define print_usage
  @. $(MAKEFILE_DIR)/make.d/scripts/print_usage.sh $(maintainer_mode)
endef

define check_cmd
  @. $(MAKEFILE_DIR)/make.d/scripts/check_cmd.sh $(cmd)
endef

define build_servers_and_tools_builder
  @. $(MAKEFILE_DIR)/make.d/scripts/build_servers_and_tools_builder.sh
endef

define build_servers_and_tools
  @. $(MAKEFILE_DIR)/make.d/scripts/build_servers_and_tools.sh
endef

define debug_build_servers_and_tools_builder
  @. $(MAKEFILE_DIR)/make.d/scripts/debug_build_servers_and_tools_builder.sh
endef

define copy_servers_conf_in_build_context
  @. $(MAKEFILE_DIR)/make.d/scripts/copy_servers_conf_in_build_context.sh
endef

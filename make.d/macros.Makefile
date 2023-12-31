define print_usage
  @. make.d/scripts/print_usage.sh $(maintainer_mode)
endef

define check_cmd
  @. make.d/scripts/check_cmd.sh $(cmd)
endef

define build_servers_and_tools_builder
  @. make.d/scripts/build_servers_and_tools_builder.sh
endef

define build_servers_and_tools
  @. make.d/scripts/build_servers_and_tools.sh
endef

define debug_build_servers_and_tools_builder
  @. make.d/scripts/debug_build_servers_and_tools_builder.sh
endef

define copy_servers_conf_in_build_context
  @. make.d/scripts/copy_servers_conf_in_build_context.sh
endef

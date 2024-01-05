define print_usage
  @. make.d/scripts/print_usage.sh $(maintainer_mode)
endef

define check_cmd
  @. make.d/scripts/check_cmd.sh $(cmd)
endef

define build_builder
  @. make.d/scripts/build_builder.sh
endef

define build_servers_and_tools
  @. make.d/scripts/build_servers_and_tools.sh
endef

define debug_build_builder
  @. make.d/scripts/debug_build_builder.sh
endef

define copy_servers_conf_in_build_context
  @. make.d/scripts/copy_servers_conf_in_build_context.sh
endef

define build_debian_upgraded
  @. make.d/scripts/build_debian_upgraded.sh
endef

define build_server_base
  @. make.d/scripts/build_server_base.sh
endef

define build_builder_base
  @. make.d/scripts/build_builder_base.sh
endef

define create_file_from_template
  @. make.d/scripts/create_file_from_template.sh $(1) $(2)
endef

define fetch_server_configuration_files
  @. make.d/scripts/fetch_server_configuration_files.sh
endef

define print_post_prepare_message
  @. make.d/scripts/print_post_prepare_message.sh
endef

define build_ide
  @. make.d/scripts/build_ide.sh
endef

define up_ide
  @. make.d/scripts/up_ide.sh
endef

define down_ide
  @. make.d/scripts/down_ide.sh
endef

define shell_ide
  @. make.d/scripts/shell_ide.sh
endef

define help
  @. make.d/scripts/help.sh $(maintainer_mode)
endef

define exec
  @. make.d/scripts/exec.sh
endef

define build_databases
  @. make.d/scripts/build_databases.sh
endef

define build_builder
  @. make.d/scripts/build_builder.sh
endef

define build_gameservers_and_tools
  @. make.d/scripts/build_gameservers_and_tools.sh
endef

define debug_build_builder
  @. make.d/scripts/debug_build_builder.sh
endef

define build_debian_upgraded
  @. make.d/scripts/build_debian_upgraded.sh
endef

define build_serverbase
  @. make.d/scripts/build_serverbase.sh
endef

define build_builderbase
  @. make.d/scripts/build_builderbase.sh
endef

define create_file_from_template
  @. make.d/scripts/create_file_from_template.sh
endef

define prepare
  @. make.d/scripts/prepare.sh
endef

define build_ide
  @. make.d/scripts/build_ide.sh
endef

define up_service_or_all
  @. make.d/scripts/up_service_or_all.sh
endef

define shell_ide
  @. make.d/scripts/shell_ide.sh
endef

define clean
  @. make.d/scripts/clean.sh
endef

define down
  @. make.d/scripts/down.sh
endef

define ensure_prepared
  @. make.d/scripts/ensure_prepared.sh
endef

define init
  @. make.d/scripts/init.sh
endef

define build_worldserver_remote_access
  @. make.d/scripts/build_worldserver_remote_access.sh
endef

define extract_conf
  @. make.d/scripts/extract_conf.sh
endef

define release_gameservers_image
  @. make.d/scripts/release_gameservers_image.sh
endef

define export_project
  @. make.d/scripts/export_project.sh
endef

define import_project
  @. make.d/scripts/import_project.sh
endef

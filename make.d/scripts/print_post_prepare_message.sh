cat << EOF
Preparation phase is done.
You may need to manual setup some stuff if not already done:

- Makefile.env
  - Make sure every variables have a value
- Makefile.maintainer.env
  - Be aware that default values can be modified according your needs
- ${AUTHSERVER_CONF_PATH}
  - Feel free to modify whatever you want in this file but...
  - Keep in mind some values may be modified for the server to work.
    - More details in the 'Makefile.env' file in commented section for the
      AUTHSERVER_CONF_PATH variable
- ${WORLDSERVER_CONF_PATH}
  - Feel free to modify whatever you want in this file but...
  - Keep in mind some values may be modified for the server to work.
    - More details in the 'Makefile.env' file in commented section for the
      WORLDSERVER_CONF_PATH variable
EOF

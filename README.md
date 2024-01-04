# Intro

**TrinityCore in docker.**

The purpose is to build docker images for databases, world server, auth server
and a remote worldserver console.
Then, it is able to run these docker images to get a fully functional
trinitycore server.

# Who

Both for trinitycore developers and trinitycore users, but with a minimum
knowledge about how docker works and minimum skills in understanding how to
build stuff from source code. You need of course the knowledge about how
trinitycore servers works and how to configure them.

# Why

Because it's cool, integrated, it is not documented in official documentation,
reproducible, totally automated and configurable.

# What

This is mainly a docker compose project which have to ouput and run docker
images.
For ease of use regarding different environment it can be run on, a Makefile
wrapper is provided to help in using the project.

# When

To initially build docker images for databases, auth server, world server and
world server remote console.
As soon as you want to update managed docker images.
To develop within trinitycore source code.
To easily run and configure a trinitycore server.
To test and play with a TrinityCore server, hey it's a fun project after all.

# How

## User mode

Using make, straightforward.
Issue `make help` and follow the guide.

**TODO: create a `guide` make target set to document use cases**

## Maintainer mode

Issue `make help maintainer_mode=1` to see usage with supplementary debugging
and inspection targets.

## Troubleshooting

You may encounter several annoyances when running make targets. Below is a list
of possible errors you may have.

### Something is wrong when I `make ...`

Using trinitycore in docker requires few things:

- a recent linux distro
- a recent docker install
- docker compose and docker buildx plugins

### make.d/env_file/Makefile.env: No such file or directory

**TODO: update this, prepare target may remove this warning/error at least,
after having created the requested file**

You have to copy the template `Makefile.env.dist` file in the `make.d/env_file`
directory to `make.d/env_file/Makefile.env`. Once it's done, `make help` should
work like a charm.
Each variable in the file `Makefile.env.dist` is documented to clarify its
purpose.
The same applies for the `Makefile.maintainer.env.dist` template file that need
to be copied into a `Makefile.maintainer.env` file.

### invalid tag "...": invalid reference format

Ensure you have set the `NAMESPACE` variable value in your
`Makefile.maintainer.env` file.

If a value is set, ensure it has a valid
format for a full qualified domain name. A valid example is `test.local`.

Ensure a version tag is correctly set in the `*_VERSION` variables.
Any value that is correct regarding docker image tag requirement will do.
For instance `0.1.0` is ok.

More generally, all variables in the `Makefile.maintainer.env.dist` file must
be set in the `Makefile.maintainer.env` file you own. Normally, default value
should be set and those warning should not appear.

### My TrinityCore servers don't start

Ensure you have provided required configuration files:

- `worldserver.conf` for the world server.
- `authserver.conf` for the authentication server.

Don't forget to set both `WORLDSERVER_CONF_PATH` and `AUTHSERVER_CONF_PATH`
variables in the `Makefile.env` file you own.

### It does not work with Docker Desktop for Windows

Nope indeed. Due to lack of compliancy with POSIX environments, it's a pain in
the a\*\* to make it work with Docker Desktop for Windows. However, don't loose
hope as it's possible to make it works with `WSL2`. I need to fine tune the
thing and provide guidance to help you setup and `WSL2` environment though.
It's on its way, be patient.

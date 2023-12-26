# Intro

**TrinityCore in docker.**

The purpose is to build docker images for databases, world, auth server and
tools.
Then, it is able to run these docker images to get a fully functional
trinitycore server.

# Who

Both for trinitycore developers and trinitycore users, but with a minimum
knowledge about how docker works and minimum skills in understanding how to
build stuff from source code. You need of course the knowledge about how
trinitycore servers works.

# Why

Because it's cool, integrated, it is not documented in official documentation,
reproducible, totally automated and configurable.

# What

This is mainly a docker compose project which have to ouput docker images.
For ease of use regarding different environment it can be run on, a Makefile
wrapper is provided to help in using the project.

# When

To initially build docker images for auth and world servers.
As soon as you want to update docker images holding the auth and world server.
To develop within trinitycore source code.
To easily run a trinitycore server.

# How

## User mode

Using make, straightforward.
Issue `make help` and follow the guide.

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

Otherwise, it's also possible to use Docker Desktop on your platform but it's
not (yet) tested.

### make.d/env_file/Makefile.env: No such file or directory

You have to copy the template `Makefile.env.dist` file in the `make.d/env_file`
directory to `make.d/env_file/Makefile.env`. Once it's done, `make help` should
work like a charm.
Each variable in the file `Makefile.env.dist` is documented to clarify its
purpose.

### invalid tag "...": invalid reference format

Ensure you have set the `FQDN` variable value in your
`make.d/env_file/Makefile.env` file.

If a value is set, ensure it has a valid
format for a full qualified domain name. A valid example is `test.local`.

Ensure a version tag is correctly set in the `SERVERS_AND_TOOLS_VERSION` or
`DATABASES_VERSION` variables.
Any value that is correct regarding docker image tag requirement will do.
For instance `0.1.0` is ok.

### My TrinityCore servers don't start

Ensure you have provided required configuration files:

- `worldserver.conf` for the world server.
- `authserver.conf` for the authentication server.

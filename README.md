# Intro

A docker compose trinitycore server builder.
The purpose is to build an alpine based docker images for databases, world and
auth server.

# Who

Both for trinitycore developers and trinitycore users, but with a minimum
knowledge about how docker works and minimum skills in understanding how to
build stuff from source code.

# Why

Because it's cool, integrated, it is not documented in official documentation,
reproducible.

# What

This is mainly a docker compose project which have to ouput docker images.
For ease of use regarding different environment it can be run on, a Makefile
wrapper is provided to help in using the project.

# When

To initially build docker images for auth and world server.
As soon as you want to update docker images holding the auth and world server.
To develop within trinitycore source code.

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

### make.d/env_file/Makefile.env: No such file or directory

You have to copy the template `Makefile.env.dist` file in the `make.d/env_file`
directory to `make.d/env_file/Makefile.env`. Once it's done, `make help` should
work like a charm.

### invalid tag "...": invalid reference format

Ensure you have set the `FQDN` variable value in your
`make.d/env_file/Makefile.env` file.

If a value is set, ensure it has a valid
format for a full qualified domain name. A valid example is `test.local`.

Ensure a version tag is correctly set in the `SERVERS_VERSION` or
`DATABASES_VERSION` variables.
Any value that is correct regarding docker image tag requirement will do.
For instance `0.1.0` is ok.

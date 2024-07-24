# Introduction

This document describe the general architecture of the `trinitycore-in-docker`
projects. Reading this should provide you sufficient insight to knwo what is
the purpose of this project and its inner details as well.

## What is `trinitycore-in-docker`

Essentially, a builder. Ideally, it is a simpler way to get a working
trinitycore server with very few efforts needed in configuration. Moreover, it
should also be seen as a complete development platform to maintain TrinityCore
providing all you need to develop, debug and test modification of the
TrinityCore project.

## How to use

It is designed to be simple and self guided:

1. `make help` is here to get a first overview
2. `make build` builds the whole thing, provided you filled necessary
   conditions. Should you have missed something, `make build` should tell it to
   you with hints to fix.
3. `make up` bring servers up and running

## Prerequisites

They differ depending the operating system you use but in general you need:

- docker (with compose and buildx plugins)
- make

### Microsoft Windows

WSL2 is mandatory. It means you must have a recent Windows version. Using this
platform requires a massive amount of tweaking because I do not provide (yet)
an automatic install process. This is because I chose not to use Docker
Desktop. Docker Desktop is fine but I experienced terrible performances using
it. I do not have any performance issues using a docker-ce manually installed
into a WSL2 Linux distribution.

To summarize:

- Docker Desktop is unsupported
- WSL2 with docker is partially supported

### MacOS

I recommend using [orbstack](https://orbstack.dev/) as an alternative to docker
desktop. It's free for a personnal usage and is very convenient to use. I use
it every day for my development endeavors.

### Linux

Not tested yet but as `trinitycore-in-docker` runs exclusively within docker
containers, any distribution capable of installing a recent docker version
should do.

#### Known issues

This is the least supported platform and using `trinitycore-in-docker` project
on it is quite experimental. You should encounter some issues depending on your
usage. Worst problem are about network stack. It is still not possible to
expose your servers through your local area network ip address. Using them
through `localhost` or `127.0.0.1` is OK though. Moreover, you **MUST** have a
very recent Windows version:

- Latest Windows 11 is fine( 23H2)
- Windows 10 (1809 build) should be OK but is not tested.

# Overview

```
+---environment----------+
|                        | <-+
|   +---make-------------+   | The user interacts with make and env variables
|   |                    | <-*
|   |   +---docker-------+
|   |   |                |
|   |   |                | <-- Docker (as well as compose and buildx) are used
|   |   |                |     under the hood. Complexity hidden to the user
+---+---+----------------+
```

# Use Cases

## Build and run servers

### Targeted users

This use case is for the category of users who want to tests a fully integrated
TrinityCore servers environment.

### Requirements

It does not require prior knowledge in software development. User should
however be acquainted with the usage of a terminal, the `make` utility and be
confortable in editing text files containing environment variable definitions.

### Usage

- Primarily `make help` to learn basics about how `trinitycore_in-docker` works
- `make build` then, figure out something is missing. Reading instructions
  leads to issue...
- `make prepare` that create several files regarding the configuration
    - Edit `Makefile.env` and initialize all mandatory things. Comments above
      each variable should help.
    - Edit `worldserver.conf` and `authserver.conf` to get a server reflecting
      your needs.
- Once again issue `make build`. If something goes wrong, follow given
  instructions. If all is ok everything is being built.
- `make up` runs the whole thing
- change the `realmlist.wtf` file according to your configuration and your
  locale

## Maintain and modify servers

### Targeted users

Enthusiast contributors/creators. primarily software developer mastering well
C++, Docker and lots of peripheral tools.

### Requirements

Good knowledge of docker and build tools for C++ projects.

### Usage

- Primarily, everything the casual user can do plus:
- `make ide` build and run a full IDE to work on servers and tools.
- `make maintainer_mode=1 help` to see what's possible to do

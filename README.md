# Intro

**TrinityCore in docker.**

The purpose is to build docker images for databases, world server, auth server
and a remote worldserver console.
Then, it is able to run these docker images to get a fully functional
trinitycore server.
Good stuff to test a server you're working on, make your first step in
TrinityCore development, play alone in your grotto just like me.

# Who

Both for trinitycore developers and trinitycore users, but with a minimum
knowledge about how docker works and minimum skills in understanding how to
build stuff from source code. You need of course the knowledge about how
trinitycore servers works and how to configure them.

# Why

Because it's cool, integrated, it is not documented in official documentation,
reproducible, totally automated and configurable.
And, I could make it. I find this very fun to make this thing.

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
Should something be unclear, please, fill a pull request and I'll be happy to
work your enhancement ideas!

### Initialize the project

using make, more especially, `make init`.
Answer questions carefully and things should be good.

## Maintainer mode

Issue `make help maintainer_mode=1` to see usage with supplementary debugging
and inspection targets. Not intended for faint of heart!

The maintainer mode is designed for... maintainers of both the
`trinitycore-in-docker` project and `TrinityCore` project.

### Initialize the project

using make, more especially, `make init maintainer_mode=1`.
Answer questions carefully and things should be good.

## Troubleshooting

You may encounter several annoyances when running make targets. Below is a list
of possible errors you may have.

### Something is wrong when I `make ...`

Using trinitycore in docker requires few things:

- a recent linux distro
- a recent docker install
- docker compose and docker buildx plugins

Normally, all those things are handled by this project and you shouldn't have
any issue with those topics unless a major breaking change somewhere...

### make.d/env_file/Makefile.env: No such file or directory

Before attempting a build, you must issue the `make prepare` command. Once this
target job is done, follow the guide!
For a more autopilot way, `make init` may help.

### invalid mount config for type "bind": field Source must not be empty

Be sure environment variables are set in your `Makefile.env` file.
This specific message error is here to say that you did not specify a valid
path to the `World of Warcraft Wrath of the Lich king` game client.

Be sure environment variables are set in your `Makefile.maintainer.env` file.
Default values should do the job if you begin to work with this repo.
If you think you screwed up (like me sometimes) with variables, just delete the
`Makefile.maintainer.env` file and issue the `make prepare` ot the `make init`
command to re-create it.
Of course, you may have to setup some value if default are not suitable for
you.
You could also, if you have already built images issue the `make extract_conf`
to retrieve configuration files directly from built images.

### Strange Warning message regarding unset variables and BLANK values...

Same as above.

### My TrinityCore servers don't start

Ensure you have provided required configuration files:

- `worldserver.conf` for the world server.
- `authserver.conf` for the authentication server.

Don't forget to set both `WORLDSERVER_CONF_PATH` and `AUTHSERVER_CONF_PATH`
variables in the `Makefile.env` file you own.
`make prepare` is your friend here.
Should you need more inspection, `make logs` could help here.

### It does not work with Docker Desktop for Windows

Nope indeed. Due to lack of compliancy with POSIX environments, it's a pain in
the a\*\* to make it work with Docker Desktop for Windows. Moreover,
performances with Docker Desktop are absolutely terrible. I do not know why and
I did not investigated much. I prefered to work on a hand-crafted docker
install on WSL2.

### But it works within WSL2

However, I need to fine tune the thing and provide guidance to help you setup
and `WSL2` environment though. It's on its way, be patient.

# Intro

A docker compose trinitycore server builder.
The purpose is to build an alpine based docker images for both the world and
the auth server.

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

Using make, straightforward.
Issue `make help` and follow the guide.

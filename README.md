# Advent Of Code Zig 2020

This repo contains my solutions from Advent of Code 2020, done in Zig.  Some days only contain solutions for part 2.  It's based on [my zig advent of code template](https://github.com/SpexGuy/Zig-AoC-Template).

### How to use this repo:

The src/ directory contains a main file for each day.  The build command `zig build dayXX [target and mode options] -- [program args]` will build and run the specified day.  You can also use `zig build install_dayXX [target and mode options]` to build the executable for a day and put it into `zig-cache/bin` without executing it.

This repo also contains Visual Studio Code project files for debugging.  These are meant to work with the C/C++ plugin.  There is a debug configuration for each day.

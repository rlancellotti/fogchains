# Open tasks

## Building
Add to makefile after INCLUDE statemente to create compile_commands.json

    CC = bear --append --output compile_commands.json -- clang
    CXX = bear --append --output compile_commands.json -- clang++

## Container
- Check container building method with new directory setup. Now fogchains is in a separate directory
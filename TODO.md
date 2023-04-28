Add to makefile after INCLUDE statemente to create compile_commands.json

CC = bear --append --output compile_commands.json -- clang
CXX = bear --append --output compile_commands.json -- clang++


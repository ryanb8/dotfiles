#!/usr/bin/env zsh

###
# This function makes it really easy to create aliases for cd'ing to specific directories
# That support auto-completion
# Example:
# # Add this to .zshrc
# make_cd_alias cdhpc /Users/long/ass/path/to/some/dir/high_performance_computing
#
# Then from any terminal location you can run
# cdhpc <tab> to see all the directories in /Users/long/ass/path/to/some/dir/high_performance_computing
#
# I use this with my gitworkflow tools (in git_workflow.sh)
# TYpically setting `cdr` to my directory where all repo providers are cloned to
# and `cdw` to my directory where my work organization (or personal github) repos are cloned to
make_cd_alias() {
  local name=$1
  local target=$2

  # Create the cd function
  eval "$name() { cd \"$target/\$1\" }"

  # Create the completion function
  eval "_$name() { _files -W \"$target\" -/ }"

  # Register completion
  compdef _$name $name
}

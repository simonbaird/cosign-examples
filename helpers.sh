#!/usr/bin/env bash

set -euo pipefail

# Output a fancy heading
function h1() {
  local text="$1"
  local line=$(sed 's/./─/g' <<< "$text")
  echo "╭─$line─╮"
  echo "┝ $text ┥"
  echo "╰─$line─╯"
}

# Output some text and wait for the user to press enter
function pause() {
  local default_msg="Press Enter to continue..."
  local msg="${1:-$default_msg}"

  nl
  if [[ ${NO_PAUSE:-""} == 1 ]]; then
    if [[ "$msg" != "$default_msg" ]]; then
      echo "$msg"
      nl
    fi
  else
    read -p "$msg"
    nl
  fi
}

# Pretty-print a command line
function show-cmd() {
  printf "\$ %s\n" "$1"
}

# Eval a command line
function run-cmd() {
  set +e
  eval "$1"
  set -e
  nl
}

# Show a command, then run it immediately
function show-then-run() {
  show-cmd "$1"
  run-cmd "$1"
}

# Show a command, then run it after the user hits enter
function pause-then-run() {
  pause "$(show-cmd "$1")"
  run-cmd "$1"
}

# Output a line break
function nl() {
  printf "\n"
}

# An aligned label and value
function show() {
  printf "%-20s %s\n" "$1:" "$2"
}

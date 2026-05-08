#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/lib/project.zsh"

typst watch --root . src/main.typ build/main.pdf

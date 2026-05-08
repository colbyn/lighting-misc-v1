#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/lib/project.zsh"

typst compile --root . src/main.typ build/main.pdf

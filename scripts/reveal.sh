#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/lib/project.zsh"

open -R "$PDF_PATH"

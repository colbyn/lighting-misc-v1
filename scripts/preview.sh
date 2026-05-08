#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/lib/project.zsh"

"$SCRIPT_DIR/build.sh"
"$SCRIPT_DIR/reveal.sh"
"$SCRIPT_DIR/open.sh"

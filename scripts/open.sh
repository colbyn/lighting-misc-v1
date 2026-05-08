#!/usr/bin/env zsh
set -euo pipefail

source "${0:A:h}/lib/project.zsh"

"$SCRIPT_DIR/build.sh"
open "$PDF_PATH"

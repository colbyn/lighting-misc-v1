#!/usr/bin/env zsh

PROJECT_LIB_DIR="${0:A:h}"
SCRIPT_DIR="${PROJECT_LIB_DIR:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
PDF_PATH="${PROJECT_DIR}/build/main.pdf"

cd "$PROJECT_DIR"

mkdir -p build

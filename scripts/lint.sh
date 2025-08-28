#!/usr/bin/env bash
set -euo pipefail

# Python linting
echo "[lint] ruff (py310, line-length=80)"
ruff check .

# Python formatting check
echo "[lint] black --check"
black --check .

# Shell linting (optional)
if command -v shellcheck >/dev/null 2>&1; then
  echo "[lint] shellcheck"
  shellcheck scripts/*.sh || true
fi

echo "lint OK"


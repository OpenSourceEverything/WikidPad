#!/usr/bin/env bash
set -euo pipefail

# Build a standalone GUI binary (folder) using PyInstaller.
# - Assumes scripts/setup.sh has prepared a venv under .venv with wxPython installed.
# - Output goes to dist/ (folder build; not onefile).
# - Run locally or in CI (release workflow calls this).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$REPO_DIR/.venv" ]]; then
  echo "Missing venv. Run scripts/setup.sh first." >&2
  exit 1
fi

source "$REPO_DIR/.venv/bin/activate"
pip install -U pyinstaller

# Build windowed app
pyinstaller \
  --name wikidpad \
  --windowed \
  --noconfirm \
  --icon "$REPO_DIR/WikidPad/icons/pwiki.ico" \
  "$REPO_DIR/WikidPad.py"

echo "Binary available under dist/"

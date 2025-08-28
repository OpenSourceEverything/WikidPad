#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$REPO_DIR/.venv" ]]; then
  echo "Missing venv. Run scripts/bootstrap.sh first." >&2
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


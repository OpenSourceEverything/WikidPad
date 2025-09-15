#!/usr/bin/env bash
set -euo pipefail

# Sanity checks that a user install works without launching the GUI.
# - Verifies venv exists, wx imports, and launcher script is present.
# - Intended to run after `make init`.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${VENV:-$REPO_DIR/.venv}"

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  echo "Missing venv. Run: make init" >&2
  exit 1
fi

echo "[test-install] python: $($VENV_DIR/bin/python -V)"

echo "[test-install] import wx"
"$VENV_DIR/bin/python" - <<'PY'
import wx
print("wx:", wx.__version__)
PY

echo "[test-install] launcher present"
test -x "$REPO_DIR/scripts/wikidpad"
grep -q "python -m WikidPad.WikidPadStarter" "$REPO_DIR/scripts/wikidpad"

echo "[test-install] ok"


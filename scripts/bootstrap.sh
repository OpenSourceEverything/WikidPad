#!/usr/bin/env bash
set -euo pipefail

# Reproducible local setup for WikidPad
# - Creates venv in ./.venv
# - Installs pinned wxPython
# - Installs project in editable mode

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$REPO_DIR/.venv"

# Prefer Python 3.10, fallback to system python3
PY_BIN="python3.10"
command -v "$PY_BIN" >/dev/null 2>&1 || PY_BIN="python3"

echo "Using Python: $PY_BIN"

if [[ ! -d "$VENV_DIR" ]]; then
  "$PY_BIN" -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
python -m pip install -U pip wheel

# Pin for repeatability (centralized)
source "$REPO_DIR/scripts/versions.sh"
if [[ "${WX_VERSION}" == "latest" ]]; then
  pip install -U wxPython
else
  pip install "wxPython==${WX_VERSION}"
fi

# Install package (provides 'wikidpad' entrypoint)
pip install -e "$REPO_DIR"

# Smoke check
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "Bootstrap complete. Run: scripts/wikidpad --wiki /path/to/Your.wiki"

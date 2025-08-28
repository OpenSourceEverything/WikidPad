#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (Linux only, best-effort, no sudo required if root)
if [[ "$(uname -s)" == "Linux" ]] && command -v apt-get >/dev/null 2>&1; then
  SUDO=""
  if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi
  $SUDO apt-get update -y || true
  # Core GUI deps (ignore if already present)
  $SUDO apt-get install -y xvfb libgtk-3-0 libgl1 || true
  # Ensure venv support exists
  $SUDO apt-get install -y python3-venv || true
fi

# 2) create isolated venv
/usr/bin/python3 -m venv .venv

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel

# 3b) install Python deps (lint/test/dev)
python -m pip install -r requirements.txt

# 4) install pinned wxPython (or latest if overridden)
source scripts/versions.sh
if [[ "${WX_VERSION}" == "latest" ]]; then
  pip install -U wxPython
else
  pip install "wxPython==${WX_VERSION}"
fi

# 5) install project for entrypoints
pip install -e .

# 6) confirm wx is importable (helps debug)
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "env ready."

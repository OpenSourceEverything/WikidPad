#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (best-effort, centralized)
bash "$(dirname "$0")/os_deps.sh"

# 2) create isolated venv (optionally including system site packages)
VENV_ARGS=""
if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
  VENV_ARGS="--system-site-packages"
fi
python3 -m venv .venv $VENV_ARGS

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel

# 3b) install Python deps (lint/test/dev)
python -m pip install -r requirements.txt

# 4) ensure wxPython is available
if python - <<'PY'
try:
    import wx
    print(wx.__version__)
    ok = True
except Exception:
    ok = False
import sys; sys.exit(0 if ok else 1)
PY
then
  echo "wxPython already available via system packages"
else
  echo "Installing wxPython via pip"
  source scripts/versions.sh
  if [[ "$(uname -s)" == "Linux" ]]; then
    WX_EXTRAS_URL="https://extras.wxpython.org/wxPython4/extras/linux/gtk3/"
    if [[ "${WX_VERSION}" == "latest" ]]; then
      pip install -U -f "$WX_EXTRAS_URL" wxPython
    else
      pip install -f "$WX_EXTRAS_URL" "wxPython==${WX_VERSION}"
    fi
  else
    if [[ "${WX_VERSION}" == "latest" ]]; then
      pip install -U wxPython
    else
      pip install "wxPython==${WX_VERSION}"
    fi
  fi
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

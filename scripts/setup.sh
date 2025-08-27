#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (Linux only) including binary wx
if [[ "${CI:-}" == "true" || "$(uname -s)" == "Linux" ]]; then
  sudo apt-get update -y
  # wx (binary), headless GUI bits, and basics
  sudo apt-get install -y \
    python3-venv \
    python3-wxgtk4.0 \
    xvfb \
    libgtk-3-0 \
    libgl1
fi

# 2) create venv that can see system site packages (so it sees python3-wxgtk4.0)
python3 -m venv .venv --system-site-packages

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel
python -m pip install -r requirements.txt

# 4) confirm wx comes from system (helps debug)
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__, "(provider: system package)")
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "env ready."

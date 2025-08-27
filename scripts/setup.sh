#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (Linux only)
if [[ "${CI:-}" == "true" || "$(uname -s)" == "Linux" ]]; then
  sudo apt-get update -y
  sudo apt-get install -y \
    python3-venv \
    python3-wxgtk4.0 \
    xvfb \
    libgtk-3-0 \
    libgl1
fi

# 2) create isolated venv
/usr/bin/python3 -m venv .venv

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel
python -m pip install -r requirements.txt

# 4) vendor system wxPython into the venv if available
if /usr/bin/python3 -c 'import wx' >/dev/null 2>&1; then
  SYS_WX_DIR=$(/usr/bin/python3 - <<'PY'
import os, wx
print(os.path.dirname(wx.__file__))
PY
)
  SYS_SITE=$(dirname "$SYS_WX_DIR")
  VENV_SITE=$(python - <<'PY'
import sysconfig
print(sysconfig.get_paths()['purelib'])
PY
)
  cp -r "$SYS_WX_DIR" "$VENV_SITE/"
  cp -r "$SYS_SITE"/wxPython* "$VENV_SITE/" 2>/dev/null || true
fi

# 5) confirm wx is importable (helps debug)
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "env ready."

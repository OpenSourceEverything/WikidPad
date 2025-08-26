#!/usr/bin/env bash
set -euo pipefail
python -m pip install -U pip
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y xvfb libgtk-3-0 libgl1
fi
pip install -r requirements.txt
python - <<'PY'
import wx
print('wx', wx.VERSION_STRING)
PY

#!/usr/bin/env bash
set -euo pipefail
python -m pip install -U pip
python -m pip install -U setuptools wheel
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y xvfb libgtk-3-0 libgl1
fi
pip install "wxPython==4.2.1"
pip install -r requirements.txt
python -c "import sys; print(sys.version)"
python -c "import wx; print('wx', wx.VERSION_STRING)"

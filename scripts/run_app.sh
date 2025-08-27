#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
. .venv/bin/activate
python - <<'PY'
import sys, wx
print(sys.version)
print("wx", wx.VERSION_STRING)
PY
# replace with your entrypoint below
# python WikidPad.py

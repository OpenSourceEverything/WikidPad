#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
bash scripts/venv.sh
bash scripts/bootstrap_wx.sh
. .venv/bin/activate
test -f requirements.txt && python -m pip install -r requirements.txt || true

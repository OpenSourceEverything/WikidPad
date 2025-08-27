#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
py="python3"
if python3.10 --version >/dev/null 2>&1; then py="python3.10"; fi
"$py" -m venv --system-site-packages .venv
. .venv/bin/activate
python -m pip install -U pip wheel

#!/usr/bin/env bash
set -euo pipefail

bash scripts/sysdeps.sh
bash scripts/venv.sh
. .venv/bin/activate

# IMPORTANT: requirements.txt must NOT list "wxPython"
# All other deps install as usual.
pip install -r requirements.txt

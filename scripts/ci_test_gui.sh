#!/usr/bin/env bash
set -euo pipefail
mkdir -p artifacts
. .venv/bin/activate
# Run under a virtual display; no GUI pops up and no build occurs.
xvfb-run -a pytest -q --maxfail=1 | tee artifacts/pytest.log

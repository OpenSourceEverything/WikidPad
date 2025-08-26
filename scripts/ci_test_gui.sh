#!/usr/bin/env bash
set -euo pipefail
export PYTEST_ADDOPTS="-q -n 0"
if command -v xvfb-run >/dev/null 2>&1; then
  xvfb-run -a pytest
else
  pytest
fi

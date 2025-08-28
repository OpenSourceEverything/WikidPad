#!/usr/bin/env bash
set -euo pipefail
mkdir -p artifacts
make test | tee artifacts/pytest.log

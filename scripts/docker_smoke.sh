#!/usr/bin/env bash
set -euo pipefail

# Build and run a Dockerized smoke test of WikidPad's GUI tests.

IMAGE="wikidpad:local"

source scripts/versions.sh
docker build --build-arg WX_VERSION="$WX_VERSION" -t "$IMAGE" .

# Override CMD to run tests directly (no venv activation needed inside image)
docker run --rm -e USE_SYSTEM_WX=1 "$IMAGE" bash -lc 'xvfb-run -a pytest -q'

echo "Docker smoke test completed."

#!/usr/bin/env bash
set -euo pipefail

# Build and run full CI (lint + init + test) inside Docker

IMAGE="wikidpad:ci"

# Source central version and pass to Docker build
source scripts/versions.sh
docker build --build-arg WX_VERSION="$WX_VERSION" -t "$IMAGE" .

docker run --rm "$IMAGE" bash -lc 'make ci'

echo "Docker CI run completed."

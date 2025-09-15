#!/usr/bin/env bash
set -euo pipefail

# Dry-run the release pipeline locally.
# - Builds PyInstaller dist and packages to release/* using a CI-style version.
# - Does not publish anywhere.
# - Cleans previous outputs under dist/ and release/ (safe in repo).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[test-release] clean old artifacts"
rm -rf "$REPO_DIR/dist" "$REPO_DIR/release"

VER="${1:-0.0.0-ci}"

echo "[test-release] make init"
make -C "$REPO_DIR" init

echo "[test-release] build + package"
bash "$REPO_DIR/scripts/release.sh" --version "$VER"

echo "[test-release] verify outputs"
test -d "$REPO_DIR/release"
ls -1 "$REPO_DIR/release" | sed 's/^/[release] /'

echo "[test-release] ok"


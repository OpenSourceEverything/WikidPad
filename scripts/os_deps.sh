#!/usr/bin/env bash
set -euo pipefail

# Install OS-level dependencies needed for WikidPad GUI and tests.
# - Safe to run multiple times
# - Uses apt-get if available; no-op otherwise

PKGS=(
  xvfb
  libgtk-3-0
  libgl1
  make
  python3-venv
)

if command -v apt-get >/dev/null 2>&1; then
  SUDO=""
  if [[ "$(id -u)" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi
  $SUDO apt-get update -y || true
  $SUDO apt-get install -y "${PKGS[@]}" || true
else
  echo "[os_deps] apt-get not found; skipping OS deps install" >&2
fi

echo "[os_deps] done"

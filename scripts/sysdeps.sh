#!/usr/bin/env bash
set -euo pipefail

# System libs + prebuilt wxPython from Ubuntu repos (NO compiling)
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y \
    xvfb \
    libgtk-3-0 \
    libgl1 \
    python3-wxgtk4.0  # <- provides the wx module (binary), no pip build
fi

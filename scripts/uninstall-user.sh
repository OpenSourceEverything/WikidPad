#!/usr/bin/env bash
set -euo pipefail

if command -v pipx >/dev/null 2>&1; then
  pipx uninstall wikidpad || true
fi

rm -f "$HOME/.local/bin/wikidpad"
echo "Uninstalled user launcher."


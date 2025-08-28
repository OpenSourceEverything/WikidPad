#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="wrapper"
if [[ "${1:-}" == "--pipx" ]]; then
  MODE="pipx"
fi

if [[ "$MODE" == "pipx" ]]; then
  if ! command -v pipx >/dev/null 2>&1; then
    echo "pipx not found. Falling back to wrapper install." >&2
  else
    # Prefer binary wheels to avoid slow source builds of wxPython
    timeout 900 pipx install "$REPO_DIR" --force \
      --pip-args='--prefer-binary' || {
      echo "pipx install failed or timed out. Falling back to wrapper." >&2
    }
  fi
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/scripts/wikidpad" "$HOME/.local/bin/wikidpad"
echo "Installed user wrapper at ~/.local/bin/wikidpad"
echo "Ensure ~/.local/bin is in PATH."

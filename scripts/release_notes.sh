#!/usr/bin/env bash
set -euo pipefail

# Generate release notes from CHANGELOG.md (Keep a Changelog style).
# Provider-neutral: intended to be called by any CI or locally.
#
# Usage:
#   scripts/release_notes.sh [--version vX.Y.Z] [--changelog CHANGELOG.md] [--out path]
#
# Behavior:
# - Extracts the section for the given version from the changelog.
# - If not found, falls back to the entire changelog.
# - Writes a markdown file suitable for release body text.

CHANGELOG="CHANGELOG.md"
OUT="RELEASE_NOTES.md"
VERSION="${VERSION:-}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
  --version VER    Version string (e.g., v2.4.0). Defaults to tag name.
  --changelog PATH Path to changelog (default: CHANGELOG.md)
  --out PATH       Output markdown file (default: RELEASE_NOTES.md)
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) shift; VERSION="${1:-}" ;;
    --version=*) VERSION="${1#*=}" ;;
    --changelog) shift; CHANGELOG="${1:-}" ;;
    --changelog=*) CHANGELOG="${1#*=}" ;;
    --out) shift; OUT="${1:-}" ;;
    --out=*) OUT="${1#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift || true
done

if [[ -z "$VERSION" ]]; then
  if [[ -n "${GITHUB_REF_NAME:-}" ]]; then
    VERSION="$GITHUB_REF_NAME"
  else
    VERSION="$(git describe --tags --always 2>/dev/null || echo "0.0.0")"
  fi
fi
VER_STRIPPED="${VERSION#v}"

[[ -r "$CHANGELOG" ]] || { echo "Missing changelog: $CHANGELOG" >&2; exit 1; }

# Extract the section matching the version header.
# Supports lines like:  ## [2.4.0] - 2025-01-01  or  ## 2.4.0 - 2025-01-01
awk -v ver="$VER_STRIPPED" '
  BEGIN { print_flag=0 }
  /^[[:space:]]*##[[:space:]]*\[?[0-9]+(\.[0-9]+)*\]?/ {
    # If we are currently printing and hit a new version header, stop.
    if (print_flag==1) { exit }
    # Check if this header matches target version
    line=$0
    gsub(/^##[[:space:]]*\[/, "", line)
    gsub(/^##[[:space:]]*/, "", line)
    gsub(/\].*$/, "", line)
    gsub(/[[:space:]]+-.*$/, "", line)
    if (line==ver) { print_flag=1; print $0; next }
  }
  { if (print_flag==1) print $0 }
' "$CHANGELOG" > "$OUT.tmp" || true

if [[ ! -s "$OUT.tmp" ]]; then
  # Fallback: entire changelog
  cp "$CHANGELOG" "$OUT.tmp"
fi

mv "$OUT.tmp" "$OUT"
echo "Wrote release notes: $OUT"


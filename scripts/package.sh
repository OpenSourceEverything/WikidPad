#!/usr/bin/env bash
set -euo pipefail

# Package built PyInstaller output into a versioned archive with checksums.
# Provider-neutral; callable locally or from any CI.
#
# Usage:
#   scripts/package.sh [--version vX.Y.Z] [--os linux|macos] \
#                      [--input-dist dist/wikidpad] [--out-dir release] [--name wikidpad]
#
# Behavior:
# - Detects version from CI tag (GITHUB_REF_NAME) or `git describe` if not given.
# - Creates ${out_dir}/${name}-${version}-${os}-${arch}.(tar.gz|zip)
# - Writes SHA256SUMS and manifest.json in out_dir

OS="linux"
INPUT_DIST="dist/wikidpad"
OUT_DIR="release"
NAME="wikidpad"
VERSION="${VERSION:-}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
  --version VER   Version string (defaults to tag or git describe)
  --os OS         linux|macos (default: linux)
  --input-dist P  Path to PyInstaller dist (default: dist/wikidpad)
  --out-dir DIR   Output directory (default: release)
  --name NAME     Base archive name (default: wikidpad)
  --sign          Create GPG detached signature for SHA256SUMS (requires gpg)
  -h, --help      Show this help
EOF
}

SIGN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) shift; VERSION="${1:-}" ;;
    --version=*) VERSION="${1#*=}" ;;
    --os) shift; OS="${1:-}" ;;
    --os=*) OS="${1#*=}" ;;
    --input-dist) shift; INPUT_DIST="${1:-}" ;;
    --input-dist=*) INPUT_DIST="${1#*=}" ;;
    --out-dir) shift; OUT_DIR="${1:-}" ;;
    --out-dir=*) OUT_DIR="${1#*=}" ;;
    --name) shift; NAME="${1:-}" ;;
    --name=*) NAME="${1#*=}" ;;
    --sign) SIGN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift || true
endone

# Derive version if not supplied
if [[ -z "$VERSION" ]]; then
  if [[ -n "${GITHUB_REF_NAME:-}" ]]; then
    VERSION="$GITHUB_REF_NAME"
  else
    VERSION="$(git describe --tags --always 2>/dev/null || echo "0.0.0")"
  fi
fi
VERSION="${VERSION#v}"

if [[ ! -d "$INPUT_DIST" ]]; then
  echo "Missing input dist: $INPUT_DIST" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

ARCH="$(uname -m || echo unknown)"
case "$OS" in
  linux)   EXT="tar.gz" ;;
  macos)   EXT="tar.gz" ;;
  *) echo "Unsupported --os: $OS" >&2; exit 2 ;;
esac

ARCHIVE_BASE="${NAME}-${VERSION}-${OS}-${ARCH}"
ARCHIVE_PATH="${OUT_DIR}/${ARCHIVE_BASE}.${EXT}"

echo "Packaging $INPUT_DIST -> $ARCHIVE_PATH"

tar -C "$(dirname "$INPUT_DIST")" -czf "$ARCHIVE_PATH" "$(basename "$INPUT_DIST")"

# Checksums
SUMS_FILE="${OUT_DIR}/SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$OUT_DIR" && sha256sum "$(basename "$ARCHIVE_PATH")") > "$SUMS_FILE"
else
  # macOS fallback
  (cd "$OUT_DIR" && shasum -a 256 "$(basename "$ARCHIVE_PATH")") > "$SUMS_FILE"
fi

echo "Wrote: $ARCHIVE_PATH"
echo "Wrote: $SUMS_FILE"

# Optional: GPG sign the checksum file (provider-neutral)
if [[ "$SIGN" -eq 1 ]]; then
  if command -v gpg >/dev/null 2>&1; then
    SIG_FILE="${SUMS_FILE}.asc"
    echo "Signing checksums -> $SIG_FILE"
    # Use provided key id/passphrase if available
    GPG_ARGS=("--batch" "--yes" "--armor" "--detach-sign" "--pinentry-mode" "loopback")
    if [[ -n "${GPG_KEY_ID:-}" ]]; then
      GPG_ARGS+=("--local-user" "${GPG_KEY_ID}")
    fi
    if [[ -n "${GPG_PASSPHRASE:-}" ]]; then
      GPG_ARGS+=("--passphrase" "${GPG_PASSPHRASE}")
    fi
    gpg "${GPG_ARGS[@]}" -o "$SIG_FILE" "$SUMS_FILE"
    echo "Wrote: $SIG_FILE"
  else
    echo "gpg not found; skipping signature" >&2
  fi
fi

# Manifest (include signature if present)
FILES_JSON='    "'"${ARCHIVE_BASE}.${EXT}"'",\n    "SHA256SUMS"'
if [[ -f "${SUMS_FILE}.asc" ]]; then
  FILES_JSON+="\n    ,\"SHA256SUMS.asc\""
fi
cat >"${OUT_DIR}/manifest.json" <<JSON
{
  "name": "${NAME}",
  "version": "${VERSION}",
  "os": "${OS}",
  "arch": "${ARCH}",
  "files": [
$FILES_JSON
  ]
}
JSON
echo "Wrote: ${OUT_DIR}/manifest.json"

#!/usr/bin/env bash
set -euo pipefail

# Provider-neutral release driver for Linux builds.
# - Single entrypoint used by GitHub Actions, Jenkins, or local shell.
# - Prepares env, builds PyInstaller dist, packages artifacts, optional sign.
#
# Usage:
#   scripts/release.sh [--version vX.Y.Z] [--os linux] [--sign]
#
# Env:
#   WX_VERSION           Pin or 'latest' (forwarded to setup.sh)
#   FORCE_WX_SOURCE=1    Force wxPython sdist build (rare)
#   GPG_PRIVATE_KEY      Optional ASCII-armored private key (imports if set)
#   GPG_KEY_ID           Signing key id (optional)
#   GPG_PASSPHRASE       Passphrase for key (optional)

OS="linux"
VERSION="${VERSION:-}"
SIGN=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]
  --version VER   Version string (defaults to tag or git describe)
  --os OS         linux (default: linux)
  --sign          Sign SHA256SUMS using gpg (if gpg available)
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) shift; VERSION="${1:-}" ;;
    --version=*) VERSION="${1#*=}" ;;
    --os) shift; OS="${1:-}" ;;
    --os=*) OS="${1#*=}" ;;
    --sign) SIGN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift || true
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load optional release config (dummy-proof)
for cfg in "$REPO_DIR/.release.env" "$REPO_DIR/scripts/release.env"; do
  if [[ -r "$cfg" ]]; then
    # shellcheck source=/dev/null
    . "$cfg"
  fi
done

# Derive version if not supplied
if [[ -z "$VERSION" ]]; then
  if [[ -n "${GITHUB_REF_NAME:-}" ]]; then
    VERSION="$GITHUB_REF_NAME"
  else
    VERSION="$(git describe --tags --always 2>/dev/null || echo "0.0.0")"
  fi
fi
VERSION="${VERSION#v}"

echo "[release] version=$VERSION os=$OS sign=$SIGN"

# Optional: import GPG key prior to packaging/signing
if [[ "$SIGN" -eq 1 && -n "${GPG_PRIVATE_KEY:-}" ]]; then
  if command -v gpg >/dev/null 2>&1; then
    echo "[release] importing GPG key"
    echo "$GPG_PRIVATE_KEY" | gpg --batch --yes --import
  else
    echo "[release] gpg not available; cannot import key" >&2
  fi
fi

# 1) Prepare isolated environment (installs wxPython + deps)
echo "[release] setup environment"
bash "$REPO_DIR/scripts/setup.sh"

# 2) Build PyInstaller binary
echo "[release] build binary"
bash "$REPO_DIR/scripts/build-pyinstaller.sh"

# 3) Package artifacts (+ optional signature)
echo "[release] package artifacts"
PKG_ARGS=("--os" "$OS" "--version" "$VERSION")
if [[ "$SIGN" -eq 1 ]]; then
  PKG_ARGS+=("--sign")
fi
bash "$REPO_DIR/scripts/package.sh" "${PKG_ARGS[@]}"

echo "[release] done (artifacts under release/)"

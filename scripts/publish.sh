#!/usr/bin/env bash
set -euo pipefail

# Provider-neutral publisher for release artifacts.
# Targets:
#   - local: copy artifacts to a directory
#   - ssh:   rsync artifacts to user@host:/path (uses ssh keys)
#   - github: create GH Release with gh CLI (optional)
#
# Usage:
#   scripts/publish.sh --target local  --dest /srv/www/downloads --version vX.Y.Z
#   scripts/publish.sh --target ssh    --dest user@host:/path     --version vX.Y.Z
#   scripts/publish.sh --target github --version vX.Y.Z \
#                       [--notes release-assets/RELEASE_NOTES.md]
#
# Env (github):
#   GH_TOKEN (or gh auth login set up) for API access

TARGET=""
DEST=""
INPUT_DIR="release"
VERSION="${VERSION:-}"
NOTES=""

usage() {
  cat <<EOF
Usage: $(basename "$0") --target TARGET --version vX.Y.Z [options]
Targets:
  local   Copy artifacts to --dest directory
  ssh     Rsync artifacts to --dest (user@host:/path)
  github  Create GitHub Release (requires gh CLI)
Options:
  --dest DIR|USER@HOST:/PATH  Destination for local/ssh targets
  --input DIR                 Source artifacts dir (default: release)
  --version VER               Tag/version (e.g., v2.4.0)
  --notes FILE                Release notes file (github target)
  -h, --help                  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) shift; TARGET="${1:-}" ;;
    --target=*) TARGET="${1#*=}" ;;
    --dest) shift; DEST="${1:-}" ;;
    --dest=*) DEST="${1#*=}" ;;
    --input) shift; INPUT_DIR="${1:-}" ;;
    --input=*) INPUT_DIR="${1#*=}" ;;
    --version) shift; VERSION="${1:-}" ;;
    --version=*) VERSION="${1#*=}" ;;
    --notes) shift; NOTES="${1:-}" ;;
    --notes=*) NOTES="${1#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift || true
done

if [[ -z "$TARGET" || -z "$VERSION" ]]; then
  echo "Missing --target or --version" >&2
  usage
  exit 2
fi

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Input dir not found: $INPUT_DIR" >&2
  exit 1
fi

case "$TARGET" in
  local)
    if [[ -z "$DEST" ]]; then
      echo "--dest required for local target" >&2
      exit 2
    fi
    mkdir -p "$DEST"
    rsync -av "$INPUT_DIR"/ "$DEST"/
    ;;
  ssh)
    if [[ -z "$DEST" ]]; then
      echo "--dest user@host:/path required for ssh target" >&2
      exit 2
    fi
    rsync -av -e ssh "$INPUT_DIR"/ "$DEST"/
    ;;
  github)
    if ! command -v gh >/dev/null 2>&1; then
      echo "gh CLI not found; install https://cli.github.com/" >&2
      exit 2
    fi
    # Ensure notes exist; generate minimal if not provided
    NOTES_FILE="${NOTES:-}"
    if [[ -z "$NOTES_FILE" ]]; then
      NOTES_FILE="release-assets/RELEASE_NOTES.md"
      mkdir -p "$(dirname "$NOTES_FILE")"
      echo "Release $VERSION" > "$NOTES_FILE"
    fi
    # Create release and upload all files from input dir
    ASSETS=()
    while IFS= read -r -d '' f; do
      ASSETS+=("$f")
    done < <(find "$INPUT_DIR" -maxdepth 1 -type f -print0)
    gh release create "$VERSION" "${ASSETS[@]}" \
      --title "$VERSION" \
      --notes-file "$NOTES_FILE" \
      --verify-tag
    ;;
  *)
    echo "Unsupported target: $TARGET" >&2
    exit 2
    ;;
esac

echo "publish done: target=$TARGET version=$VERSION"


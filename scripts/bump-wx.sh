#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new_wx_version|latest>" >&2
  exit 1
fi

NEW_VER="$1"

# Update scripts/versions.sh
sed -i.bak -E "s/^(WX_VERSION=\").*(\")/\1${NEW_VER}\2/" scripts/versions.sh || true
rm -f scripts/versions.sh.bak

# Update Dockerfile ARG default
sed -i.bak -E "s/^(ARG WX_VERSION=).*/\1${NEW_VER}/" Dockerfile || true
rm -f Dockerfile.bak

echo "Bumped wxPython version to: ${NEW_VER}"
echo "Run: git add -p && make docker-ci"


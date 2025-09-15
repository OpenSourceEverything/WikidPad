#!/usr/bin/env bash
set -euo pipefail

# Run WikidPad CI across a matrix of Linux distros locally using Docker.
# Default: run all distros listed in scripts/distros.list
# Filter:  --only <name>  run a single target by its name (first column)
#          --list         list available targets and exit

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
LIST_FILE="${LIST_FILE:-${SCRIPT_DIR}/distros.list}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--only NAME] [--list]
Runs 'bash scripts/os_deps.sh && make ci' inside each distro container.

Options:
  --only NAME   Run only the named target from distros.list
  --list        List targets and exit
  -h, --help    Show this help

Environment:
  USE_SYSTEM_WX=1  Expose system wxPython inside venv (default: 1)
  LIST_FILE=path   Path to distros.list (default: scripts/distros.list)
EOF
}

ONLY=""
LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      shift; ONLY="${1:-}"; [[ -n "$ONLY" ]] || { echo "--only requires a name" >&2; exit 2; } ;;
    --only=*)
      ONLY="${1#*=}" ;;
    --list)
      LIST=1 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; usage; exit 2 ;;
  esac
  shift || true
done

command -v docker >/dev/null 2>&1 || { echo "docker not found in PATH" >&2; exit 1; }
[[ -r "$LIST_FILE" ]] || { echo "Missing list file: $LIST_FILE" >&2; exit 1; }

mapfile -t ROWS < <(grep -vE '^(\s*#|\s*$)' "$LIST_FILE")
if [[ ${#ROWS[@]} -eq 0 ]]; then
  echo "No entries in $LIST_FILE" >&2; exit 1
fi

if [[ "$LIST" -eq 1 ]]; then
  printf "%s\n" "${ROWS[@]}"
  exit 0
fi

run_one() {
  local name="$1" image="$2"
  echo "=== [${name}] image=${image} ==="
  # Remove any host venv to avoid cross-distro contamination
  rm -rf "$REPO_DIR/.venv" || true
  # Run container as host user to avoid root-owned artifacts on the mount
  DOCKER_UIDGID="$(id -u):$(id -g)"
  docker run --rm -t \
    -u "$DOCKER_UIDGID" \
    -v "$REPO_DIR":/app -w /app \
    -e USE_SYSTEM_WX="${USE_SYSTEM_WX:-1}" \
    -e VENV="/tmp/venv-${name}" \
    "$image" \
    bash -lc 'bash scripts/os_deps.sh && make ci'
  # Collect artifacts per distro to avoid overwrites
  if [[ -d "$REPO_DIR/artifacts" ]]; then
    mkdir -p "$REPO_DIR/artifacts-matrix/$name"
    mv "$REPO_DIR/artifacts" "$REPO_DIR/artifacts-matrix/$name/" || true
  else
    mkdir -p "$REPO_DIR/artifacts-matrix/$name"
  fi
}

FAILS=()
for row in "${ROWS[@]}"; do
  # split on whitespace: name image (collapse multiple spaces)
  IFS=' 	' read -r name image <<<"$row"
  if [[ -n "$ONLY" && "$name" != "$ONLY" ]]; then
    continue
  fi
  if ! run_one "$name" "$image"; then
    FAILS+=("$name")
  fi
done

if [[ -n "$ONLY" && ${#FAILS[@]} -eq 1 ]]; then
  echo "Single target failed: ${FAILS[0]}" >&2
  exit 1
fi

if [[ ${#FAILS[@]} -gt 0 ]]; then
  echo "Failures: ${FAILS[*]}" >&2
  exit 1
fi

echo "All targets completed."

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
  local run_rc=0
  local log_dir="$REPO_DIR/artifacts-matrix/$name"
  local log_file="$log_dir/docker.log"
  echo "=== [${name}] image=${image} ==="
  # Remove any host venv to avoid cross-distro contamination
  rm -rf "$REPO_DIR/.venv" || true
  mkdir -p "$log_dir"
  # Run as root so os_deps.sh can install distro packages even when sudo is absent.
  # Restore file ownership on the mounted repo before exit.
  HOST_UID="$(id -u)"
  HOST_GID="$(id -g)"
  docker run --rm -t \
    -v "$REPO_DIR":/app -w /app \
    -e USE_SYSTEM_WX="${USE_SYSTEM_WX:-1}" \
    -e FORCE_WX_SOURCE=0 \
    -e WX_VERSION="${WX_VERSION:-latest}" \
    -e VENV="/tmp/venv-${name}" \
    -e HOST_UID="$HOST_UID" \
    -e HOST_GID="$HOST_GID" \
    "$image" \
    bash -lc '
      rc=0
      bash scripts/os_deps.sh && make ci || rc=$?
      chown -R "${HOST_UID}:${HOST_GID}" /app >/dev/null 2>&1 || true
      exit "$rc"
    ' >"$log_file" 2>&1 || run_rc=$?
  cat "$log_file"
  if [[ "$run_rc" -ne 0 ]]; then
    phase="$(grep -Eo '\[ci\] [a-z]+' "$log_file" | tail -n 1 | sed 's/\[ci\] //')"
    hint="$(tail -n 3 "$log_file" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g' || true)"
    if [[ -z "${hint:-}" || "$hint" =~ make:\ \*\*\* ]]; then
      hint="$(grep -Ei 'wx import failed|No matching distribution found|ERROR: Could not|ModuleNotFoundError|Traceback|Fallback to latest also failed|wxPython import still failing|unbound variable|command not found|No such file or directory|Permission denied|^E: |error:' "$log_file" | tail -n 1 || true)"
    fi
    echo "::error::[${name}] failed (rc=${run_rc}, phase=${phase:-unknown}) ${hint}"
  fi
  # Collect artifacts per distro to avoid overwrites
  if [[ -d "$REPO_DIR/artifacts" ]]; then
    mv "$REPO_DIR/artifacts" "$log_dir/" || true
  fi
  return "$run_rc"
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
  echo "::error::Failures: ${FAILS[*]}"
  echo "Failures: ${FAILS[*]}" >&2
  exit 1
fi

echo "All targets completed."

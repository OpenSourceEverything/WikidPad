#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (best-effort, centralized)
# Uses centralized wxPython pin from scripts/versions.sh when present
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
VENV_DIR="${VENV:-.venv}"
# Install base OS deps; if FORCE_WX_SOURCE=1, os_deps.sh will include dev headers
bash "$SCRIPT_DIR/os_deps.sh"

# 2) create isolated venv (optionally expose system site-packages for OS wx)
VENV_FLAGS=()
if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
  VENV_FLAGS+=("--system-site-packages")
elif [[ -n "${VENV_FLAGS:-}" ]]; then
  : # keep empty for clarity
fi
if [[ -d "$VENV_DIR" && -x "$VENV_DIR/bin/python" ]]; then
  echo "Using existing venv: $VENV_DIR"
else
  rm -rf "$VENV_DIR" 2>/dev/null || true
  python3 -m venv "$VENV_DIR" "${VENV_FLAGS[@]}"
fi

VENV_PY="$VENV_DIR/bin/python"

# 3) upgrade pip/wheel and install Python deps using the venv interpreter
"$VENV_PY" -m pip install -U pip wheel

# 3b) install Python deps (lint/test/dev)
"$VENV_PY" -m pip install -r "$REPO_DIR/requirements.txt"
WX_BINARY_WHEEL_FAILED=0

# 4) ensure wxPython is available (binary by default; opt-in source build)
if [[ "${FORCE_WX_SOURCE:-}" == "1" ]]; then
  echo "FORCE_WX_SOURCE=1: installing wxPython from source (sdist)"
  if [[ -r "$SCRIPT_DIR/versions.sh" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/versions.sh"
  fi
  : "${WX_VERSION:=4.2.1}"
  if [[ "${WX_VERSION}" == "latest" ]]; then
    "$VENV_PY" -m pip install --no-binary=wxPython wxPython
  else
    "$VENV_PY" -m pip install --no-binary=wxPython "wxPython==${WX_VERSION}"
  fi
else
  # Attempt to import first; otherwise install binary wheel using extras index
  if "$VENV_PY" - <<'PY'
try:
    import wx
    print(wx.__version__)
    ok = True
except Exception:
    ok = False
import sys; sys.exit(0 if ok else 1)
PY
  then
    echo "wxPython already available"
  else
    echo "Installing wxPython via pip (binary wheels only)"
    if [[ -r "$SCRIPT_DIR/versions.sh" ]]; then
      # shellcheck source=/dev/null
      source "$SCRIPT_DIR/versions.sh"
    fi
    : "${WX_VERSION:=4.2.1}"
    if [[ "$(uname -s)" == "Linux" ]]; then
      EXTRAS_BASE="https://extras.wxpython.org/wxPython4/extras/linux/gtk3"
      # Build a list of candidate extras indexes to avoid source builds on newer LTS
      CANDIDATES=()
      if [[ -r /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "${ID:-}-${VERSION_ID:-}" in
          ubuntu-24.04*) CANDIDATES+=("$EXTRAS_BASE/ubuntu-24.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/debian-11/") ;;
          ubuntu-22.04*) CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/debian-11/") ;;
          debian-12*)    CANDIDATES+=("$EXTRAS_BASE/ubuntu-24.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") ;;
          debian-11*)    CANDIDATES+=("$EXTRAS_BASE/debian-11/") \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") ;;
          arch-*|manjaro-*|endeavouros-*|garuda-*) \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-24.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/debian-11/") ;;
          *)             CANDIDATES+=("$EXTRAS_BASE/ubuntu-24.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") \
                                CANDIDATES+=("$EXTRAS_BASE/debian-11/") \
                                CANDIDATES+=("$EXTRAS_BASE/") ;;
        esac
      else
        CANDIDATES+=("$EXTRAS_BASE/ubuntu-24.04/")
        CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/")
        CANDIDATES+=("$EXTRAS_BASE/debian-11/")
        CANDIDATES+=("$EXTRAS_BASE/")
      fi

      PIP_FLAGS=("--prefer-binary" "--only-binary=:all:")
      for url in "${CANDIDATES[@]}"; do
        PIP_FLAGS+=("-f" "$url")
      done

      if [[ "${WX_VERSION}" == "latest" ]]; then
        if ! "$VENV_PY" -m pip install -U "${PIP_FLAGS[@]}" wxPython; then
          echo "No compatible wxPython binary wheel found for this distro (latest)." >&2
          WX_BINARY_WHEEL_FAILED=1
        fi
      else
        if ! "$VENV_PY" -m pip install "${PIP_FLAGS[@]}" "wxPython==${WX_VERSION}"; then
          echo "No compatible wxPython ${WX_VERSION} binary wheel found for this distro." >&2
          echo "Tried indexes: ${CANDIDATES[*]}" >&2
          echo "Falling back to latest available wheel." >&2
          if ! "$VENV_PY" -m pip install -U "${PIP_FLAGS[@]}" wxPython; then
            echo "Fallback to latest also failed." >&2
            WX_BINARY_WHEEL_FAILED=1
          fi
        fi
      fi
      if [[ "$WX_BINARY_WHEEL_FAILED" == "1" ]]; then
        echo "Will continue and try system wxPython fallback in step 6." >&2
      fi
    else
      if [[ "${WX_VERSION}" == "latest" ]]; then
        "$VENV_PY" -m pip install -U --prefer-binary --only-binary=:all: wxPython
      else
        "$VENV_PY" -m pip install --prefer-binary --only-binary=:all: "wxPython==${WX_VERSION}"
      fi
    fi
  fi
fi

# 5) install project for entrypoints
"$VENV_PY" -m pip install -e "$REPO_DIR"

# 6) confirm wx is importable; if not, fall back to system wx (auto)
if ! "$VENV_PY" - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit(f"wx import failed: {e!r}")
PY
then
  echo "Attempting fallback to system wxPython (auto)" >&2
  # 6a) install system wx via OS packages (best-effort)
  USE_SYSTEM_WX=1 bash "$SCRIPT_DIR/os_deps.sh" || true
  # 6b) recreate venv with access to system site-packages
  rm -rf "$VENV_DIR" 2>/dev/null || true
  python3 -m venv "$VENV_DIR" --system-site-packages
  VENV_PY="$VENV_DIR/bin/python"
  "$VENV_PY" -m pip install -U pip wheel
  "$VENV_PY" -m pip install -r "$REPO_DIR/requirements.txt"
  "$VENV_PY" -m pip install -e "$REPO_DIR"
  # 6c) verify again
  if ! "$VENV_PY" - <<'PY'
try:
    import wx
    print("wxPython(system):", wx.__version__)
except Exception as e:
    raise SystemExit(f"wx import failed after system fallback: {e!r}")
PY
  then
    echo "wxPython import still failing after system fallback. See above for details." >&2
    exit 1
  fi
fi

echo "env ready."

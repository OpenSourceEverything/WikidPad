#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (best-effort, centralized)
# Uses centralized wxPython pin from scripts/versions.sh when present
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
bash "$SCRIPT_DIR/os_deps.sh"

# 2) create isolated venv (optionally expose system site-packages for OS wx)
VENV_FLAGS=()
if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
  VENV_FLAGS+=("--system-site-packages")
fi
python3 -m venv .venv "${VENV_FLAGS[@]}"

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel

# 3b) install Python deps (lint/test/dev)
python -m pip install -r "$REPO_DIR/requirements.txt"

# 4) ensure wxPython is available
if python - <<'PY'
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
                              CANDIDATES+=("$EXTRAS_BASE/debian-12/") ;;
        ubuntu-22.04*) CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") \
                              CANDIDATES+=("$EXTRAS_BASE/debian-12/") ;;
        debian-12*)    CANDIDATES+=("$EXTRAS_BASE/debian-12/") \\
                              CANDIDATES+=("$EXTRAS_BASE/ubuntu-22.04/") ;;
        debian-11*)    CANDIDATES+=("$EXTRAS_BASE/debian-11/") ;;
        *)             CANDIDATES+=("$EXTRAS_BASE/") ;;
      esac
    else
      CANDIDATES+=("$EXTRAS_BASE/")
    fi

    PIP_FLAGS=("--prefer-binary" "--only-binary=:all:")
    for url in "${CANDIDATES[@]}"; do
      PIP_FLAGS+=("-f" "$url")
    done

    if [[ "${WX_VERSION}" == "latest" ]]; then
      if ! python -m pip install -U "${PIP_FLAGS[@]}" wxPython; then
        echo "No compatible wxPython binary wheel found for this distro (latest)." >&2
        exit 1
      fi
    else
      if ! python -m pip install "${PIP_FLAGS[@]}" "wxPython==${WX_VERSION}"; then
        echo "No compatible wxPython ${WX_VERSION} binary wheel found for this distro." >&2
        echo "Tried indexes: ${CANDIDATES[*]}" >&2
        exit 1
      fi
    fi
  else
    if [[ "${WX_VERSION}" == "latest" ]]; then
      python -m pip install -U --prefer-binary --only-binary=:all: wxPython
    else
      python -m pip install --prefer-binary --only-binary=:all: "wxPython==${WX_VERSION}"
    fi
  fi
fi

# 5) install project for entrypoints
python -m pip install -e "$REPO_DIR"

# 6) confirm wx is importable (helps debug)
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "env ready."

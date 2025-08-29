#!/usr/bin/env bash
set -euo pipefail

# 1) install system deps (best-effort, centralized)
bash "$(dirname "$0")/os_deps.sh"

# 2) create isolated venv
python3 -m venv .venv

# 3) upgrade pip/wheel and install Python deps
. .venv/bin/activate
python -m pip install -U pip wheel

# 3b) install Python deps (lint/test/dev)
python -m pip install -r requirements.txt

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
  echo "Installing wxPython via pip"
  source scripts/versions.sh
  if [[ "$(uname -s)" == "Linux" ]]; then
    # Select distro-specific extras path to fetch prebuilt wheels
    EXTRAS_BASE="https://extras.wxpython.org/wxPython4/extras/linux/gtk3"
    DISTRO_DIR=""
    if [[ -r /etc/os-release ]]; then
      . /etc/os-release
      case "${ID}-${VERSION_ID}" in
        ubuntu-22.04*) DISTRO_DIR="ubuntu-22.04" ;;
        ubuntu-24.04*) DISTRO_DIR="ubuntu-24.04" ;;
        debian-12*)    DISTRO_DIR="debian-12" ;;
        debian-11*)    DISTRO_DIR="debian-11" ;;
      esac
    fi
    if [[ -n "$DISTRO_DIR" ]]; then
      WX_EXTRAS_URL="$EXTRAS_BASE/$DISTRO_DIR/"
    else
      WX_EXTRAS_URL="$EXTRAS_BASE/"
    fi
    if [[ "${WX_VERSION}" == "latest" ]]; then
      pip install -U -f "$WX_EXTRAS_URL" wxPython || pip install -U wxPython
    else
      pip install -f "$WX_EXTRAS_URL" "wxPython==${WX_VERSION}" || pip install "wxPython==${WX_VERSION}"
    fi
  else
    if [[ "${WX_VERSION}" == "latest" ]]; then
      pip install -U wxPython
    else
      pip install "wxPython==${WX_VERSION}"
    fi
  fi
fi

# 5) install project for entrypoints
pip install -e .

# 6) confirm wx is importable (helps debug)
python - <<'PY'
try:
    import wx
    print("wxPython:", wx.__version__)
except Exception as e:
    raise SystemExit("wx import failed: %r" % (e,))
PY

echo "env ready."

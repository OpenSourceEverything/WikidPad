#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
. .venv/bin/activate
if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get required"; exit 2
fi
. /etc/os-release
vid="${VERSION_ID:-}"
sudo true 2>/dev/null || true
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi
$SUDO apt-get update
$SUDO apt-get install -y \
  xvfb libgtk-3-0 libgl1 libnotify4 libsm6 libxrender1 libxext6 \
  libxtst6 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
  libsdl2-2.0-0 libjpeg-turbo8 libpcre2-32-0 ca-certificates curl
if [ "$vid" = "22.04" ]; then
  URL="https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-22.04"
  python -m pip install -f "$URL" wxPython==4.2.1
else
  $SUDO apt-get install -y python3-wxgtk4.0
fi
python - <<'PY'
import wx
print("wx", wx.VERSION_STRING)
PY

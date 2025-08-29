#!/usr/bin/env bash
# Cross‑distro OS deps for WikidPad GUI/tests
# - Best‑effort installs; safe to run repeatedly
# - If USE_SYSTEM_WX=1, attempt to install wxPython from the OS where available
set -euo pipefail

log()  { printf '[os_deps] %s\n' "$*"; }
warn() { printf '[os_deps][warn] %s\n' "$*" >&2; }

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

# Try to install one of the provided package names with the given command
try_install() {
  local base_cmd="$1"; shift || true
  local names=("$@")
  for name in "${names[@]}"; do
    if [[ -n "$name" ]]; then
      if $base_cmd "$name" >/dev/null 2>&1; then
        log "installed: $name"
        return 0
      fi
    fi
  done
  return 1
}

PM=""
if command -v apt-get >/dev/null 2>&1; then
  PM="apt"
elif command -v dnf >/dev/null 2>&1; then
  PM="dnf"
elif command -v yum >/dev/null 2>&1; then
  PM="yum"
elif command -v zypper >/dev/null 2>&1; then
  PM="zypper"
elif command -v pacman >/dev/null 2>&1; then
  PM="pacman"
elif command -v apk >/dev/null 2>&1; then
  PM="apk"
elif command -v brew >/dev/null 2>&1; then
  PM="brew"
elif command -v choco >/dev/null 2>&1; then
  PM="choco"
fi

case "$PM" in
  apt)
    $SUDO apt-get update -y || true
    $SUDO apt-get install -y \
      make xvfb libgtk-3-0 libgl1 libnotify4 \
      python3 python3-pip python-is-python3 python3-venv \
      || true
    # SDL2 runtime (name differs across Ubuntu versions)
    try_install "$SUDO apt-get install -y" libsdl2-2.0-0t64 libsdl2-2.0-0 || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      try_install "$SUDO apt-get install -y" python3-wxgtk4.0 || true
    fi
    ;;

  dnf)
    $SUDO dnf -y install \
      make xorg-x11-server-Xvfb xorg-x11-xauth gtk3 mesa-libGL libnotify \
      python3 python3-pip || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      $SUDO dnf -y install python3-wxpython4 || true
    fi
    ;;

  yum)
    $SUDO yum -y install \
      make xorg-x11-server-Xvfb xorg-x11-xauth gtk3 mesa-libGL libnotify \
      python3 python3-pip || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      $SUDO yum -y install python3-wxpython4 || true
    fi
    ;;

  zypper)
    $SUDO zypper --non-interactive refresh || true
    $SUDO zypper --non-interactive install -y \
      make xorg-x11-Xvfb xauth gtk3 Mesa-libGL1 libnotify-tools \
      python3 python3-pip || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      try_install "$SUDO zypper --non-interactive install -y" \
        python3-wxPython python3-wxWidgets-4_0 python3-wxWidgets-4_1 || true
    fi
    ;;

  pacman)
    $SUDO pacman -Sy --noconfirm || true
    $SUDO pacman -S --noconfirm \
      make xorg-server-xvfb xorg-xauth gtk3 mesa libnotify \
      python python-pip || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      $SUDO pacman -S --noconfirm wxpython || true
    fi
    ;;

  apk)
    # Alpine (musl) lacks reliable wxPython wheels; only best-effort base libs
    $SUDO apk add --no-cache \
      make xvfb xauth gtk+3.0 mesa-gl libnotify \
      python3 py3-pip || true
    if [[ "${USE_SYSTEM_WX:-}" == "1" ]]; then
      warn "wxPython system package not available on Alpine (skipping)"
    fi
    ;;

  brew)
    brew update || true
    brew install gtk+3 mesa libnotify python || true
    warn "macOS: headless GUI via Xvfb is not typical; skipping XQuartz here."
    ;;

  choco)
    warn "Windows handled in release pipeline; skipping."
    ;;

  *)
    warn "No supported package manager found; skipping OS deps install."
    ;;
esac

log "done"

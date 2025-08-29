#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="wrapper"
DO_ASSOC=1

for arg in "${@:-}"; do
  case "${arg}" in
    --pipx) MODE="pipx" ;;
    --no-assoc) DO_ASSOC=0 ;;
  esac
done

if [[ "$MODE" == "pipx" ]]; then
  if ! command -v pipx >/dev/null 2>&1; then
    echo "pipx not found. Falling back to wrapper install." >&2
  else
    # Prefer binary wheels to avoid slow source builds of wxPython
    timeout 900 pipx install "$REPO_DIR" --force \
      --pip-args='--prefer-binary' || {
      echo "pipx install failed or timed out. Falling back to wrapper." >&2
    }
  fi
fi

# 1) CLI launcher
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/scripts/wikidpad" "$HOME/.local/bin/wikidpad"
echo "Installed user launcher: $HOME/.local/bin/wikidpad"
echo "Ensure ~/.local/bin is in PATH."

# 2) Desktop entry and icon (user scope)
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/128x128/apps"
mkdir -p "$APP_DIR" "$ICON_DIR"

# Choose an icon from repo (fallback-safe)
SRC_ICON="$REPO_DIR/WikidPad/Wikidpad_128x128x32.png"
DEST_ICON="$ICON_DIR/wikidpad.png"
if [[ -f "$SRC_ICON" ]]; then
  cp -f "$SRC_ICON" "$DEST_ICON"
  echo "Installed icon: $DEST_ICON"
else
  echo "Icon not found at $SRC_ICON (skipping icon copy)" >&2
fi

DESKTOP_FILE="$APP_DIR/wikidpad.desktop"
cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Name=WikidPad
Comment=Personal wiki
Type=Application
TryExec=wikidpad
Exec=wikidpad --wiki %f
Icon=wikidpad
Terminal=false
Categories=Office;Utility;
MimeType=text/x-wiki;
EOF
echo "Installed desktop entry: $DESKTOP_FILE"

# Refresh desktop entries (if tool exists)
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" || true
fi

# 3) User MIME mapping for .wiki → text/x-wiki
MIME_DIR="$HOME/.local/share/mime"
MIME_PKG_DIR="$MIME_DIR/packages"
mkdir -p "$MIME_PKG_DIR"
MIME_XML="$MIME_PKG_DIR/wikidpad.xml"
cat > "$MIME_XML" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="text/x-wiki">
    <comment>WikidPad Wiki file</comment>
    <glob pattern="*.wiki"/>
  </mime-type>
</mime-info>
EOF
echo "Installed user MIME XML: $MIME_XML"
if command -v update-mime-database >/dev/null 2>&1; then
  update-mime-database "$MIME_DIR" || true
fi

# 4) Optionally set default handler for text/x-wiki
if [[ "$DO_ASSOC" -eq 1 ]] && command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default wikidpad.desktop text/x-wiki || true
  echo "Associated text/x-wiki with wikidpad.desktop (user scope)"
else
  echo "Skipping default handler association (use --no-assoc to suppress, or run: xdg-mime default wikidpad.desktop text/x-wiki)"
fi

echo "User installation complete. Try: wikidpad --wiki /path/to/Your.wiki"

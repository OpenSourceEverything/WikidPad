#!/usr/bin/env bash
# improved uninstall helper for wikidpad
# safe: no sudo, no root writes; prints exact next steps
# usage: bash uninstall_wikidpad.sh
set -euo pipefail

USER_LAUNCHER="$HOME/.local/bin/wikidpad"
SYSTEM_LAUNCHER="/usr/local/bin/wikidpad"
NAME="wikidpad"

say() { printf "%s\n" "$*"; }

# 1) pipx uninstall (ignore if not installed)
if command -v pipx >/dev/null 2>&1; then
  pipx uninstall "$NAME" || true
fi

# 2) remove user launcher
if [ -e "$USER_LAUNCHER" ]; then
  rm -f "$USER_LAUNCHER"
  say "removed user launcher: $USER_LAUNCHER"
else
  say "no user launcher at: $USER_LAUNCHER"
fi

# 2b) remove user .desktop entry and refresh
DESKTOP="$HOME/.local/share/applications/wikidpad.desktop"
if [ -f "$DESKTOP" ]; then
  rm -f "$DESKTOP"
  command -v update-desktop-database >/dev/null 2>&1 && \
    update-desktop-database "$HOME/.local/share/applications" || true
  say "removed desktop entry: $DESKTOP"
else
  say "no desktop entry at: $DESKTOP"
fi

# 2c) remove MIME associations pointing to wikidpad.desktop
for mf in "$HOME/.config/mimeapps.list" \
          "$HOME/.local/share/applications/mimeapps.list"
do
  [ -f "$mf" ] || continue
  cp -f "$mf" "$mf.bak" || true
  sed -i -E '/^text\/x-wiki=.*wikidpad\.desktop/d; \
             /^application\/x-wikidpad=.*wikidpad\.desktop/d' "$mf" || true
  say "cleaned MIME mappings in: $mf (backup: $mf.bak)"
done

# 2d) remove custom MIME XML
MIME_XML="$HOME/.local/share/mime/packages/wikidpad.xml"
if [ -f "$MIME_XML" ]; then
  rm -f "$MIME_XML"
  command -v update-mime-database >/dev/null 2>&1 && \
    update-mime-database "$HOME/.local/share/mime" || true
  say "removed MIME XML: $MIME_XML"
fi

# 2b) remove user .desktop entry and refresh
DESKTOP="$HOME/.local/share/applications/wikidpad.desktop"
if [ -f "$DESKTOP" ]; then
  rm -f "$DESKTOP"
  command -v update-desktop-database >/dev/null 2>&1 && \
    update-desktop-database "$HOME/.local/share/applications" || true
  say "removed desktop entry: $DESKTOP"
else
  say "no desktop entry at: $DESKTOP"
fi

# 2c) remove MIME associations pointing to wikidpad.desktop
for mf in "$HOME/.config/mimeapps.list" \
          "$HOME/.local/share/applications/mimeapps.list"
do
  [ -f "$mf" ] || continue
  cp -f "$mf" "$mf.bak" || true
  sed -i -E '/^text\/x-wiki=.*wikidpad\.desktop/d; \
             /^application\/x-wikidpad=.*wikidpad\.desktop/d' "$mf" || true
  say "cleaned MIME mappings in: $mf (backup: $mf.bak)"
done

# 2d) remove custom MIME XML (if it was ever installed)
MIME_XML="$HOME/.local/share/mime/packages/wikidpad.xml"
if [ -f "$MIME_XML" ]; then
  rm -f "$MIME_XML"
  command -v update-mime-database >/dev/null 2>&1 && \
    update-mime-database "$HOME/.local/share/mime" || true
  say "removed MIME XML: $MIME_XML"
fi

# 2e) warn if default handler for text/x-wiki is still wikidpad
if command -v xdg-mime >/dev/null 2>&1; then
  cur=$(xdg-mime query default text/x-wiki 2>/dev/null || true)
  if [ "$cur" = "wikidpad.desktop" ]; then
    say "text/x-wiki still defaults to wikidpad.desktop."
    say "set another app, e.g.: xdg-mime default org.gnome.gedit.desktop text/x-wiki"
  fi
fi

# 3) show other launchers in PATH
# avoids false sense of uninstall if copies elsewhere
FOUND=0
IFS=":" read -r -a P_ARR <<< "${PATH:-}"
for d in "${P_ARR[@]}"; do
  f="$d/$NAME"
  if [ -e "$f" ]; then
    FOUND=1
    t="file"
    [ -L "$f" ] && t="symlink -> $(readlink "$f")"
    own="$(stat -c '%U:%G' "$f" 2>/dev/null || echo '?')"
    say "found: $f ($t) owner=$own"
  fi
done
[ "$FOUND" -eq 0 ] && say "no other launchers found in PATH"

# 4) handle system launcher info and next actions
if [ -e "$SYSTEM_LAUNCHER" ]; then
  if [ -w "$SYSTEM_LAUNCHER" ]; then
    rm -f "$SYSTEM_LAUNCHER"
    say "removed system launcher: $SYSTEM_LAUNCHER"
  else
    say "system launcher exists: $SYSTEM_LAUNCHER"
    if [ -L "$SYSTEM_LAUNCHER" ]; then
      say "symlink target: $(readlink -f "$SYSTEM_LAUNCHER" 2>/dev/null || \
readlink "$SYSTEM_LAUNCHER")"
    fi
    # package ownership hints (debian/rpm/homebrew)
    if command -v dpkg >/dev/null 2>&1; then
      dpkg -S "$SYSTEM_LAUNCHER" 2>/dev/null || true
    fi
    if command -v rpm >/dev/null 2>&1; then
      rpm -qf "$SYSTEM_LAUNCHER" 2>/dev/null || true
    fi
    if command -v brew >/dev/null 2>&1; then
      brew --prefix >/dev/null 2>&1 && \
say "brew candidate: try brew which $NAME or brew list"
    fi
    say "to remove: sudo rm $SYSTEM_LAUNCHER"
    say "or check package owner first:"
    say "  dpkg -S $SYSTEM_LAUNCHER 2>/dev/null || true"
    say "  rpm -qf $SYSTEM_LAUNCHER 2>/dev/null || true"
  fi
else
  say "no system launcher at: $SYSTEM_LAUNCHER"
fi

# 5) update shell command caches
hash -r 2>/dev/null || true
if [ -n "${ZSH_VERSION:-}" ]; then
  rehash 2>/dev/null || true
fi

# 6) final state
W="$(command -v "$NAME" 2>/dev/null || true)"
if [ -n "$W" ]; then
  say "still resolves to: $W"
else
  say "wikidpad no longer on PATH"
fi

say "done."

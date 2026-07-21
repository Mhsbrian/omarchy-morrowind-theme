#!/usr/bin/env bash
# Uninstaller for the Morrowind Omarchy theme. Mirrors install.sh.
#
#   ./uninstall.sh [options]
#
#   --with-lockscreen   Also remove the themed lock screen and restore the
#                       default hyprlock flow (reverses hypridle + keybind).
#   --keep-theme        Remove only extras; keep the base Morrowind theme.
#   --dry-run           Print actions without changing anything.
#   -h, --help          Show this help.
#
# Removing a theme deletes only its source under ~/.config/omarchy/themes. If it
# is the active theme, switch to another first (Omarchy runs from a copy).
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

DO_LOCK=0 KEEP_THEME=0
usage() { sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-lockscreen) DO_LOCK=1 ;;
    --keep-theme)      KEEP_THEME=1 ;;
    --dry-run)         DRY_RUN=1 ;;
    -h|--help)         usage 0 ;;
    *) err "unknown argument: $1"; usage 1 ;;
  esac
  shift
done

is_live() { [[ $DRY_RUN == 0 && $DEST_HOME == "$HOME" ]]; }
active_theme() { tr '[:upper:] ' '[:lower:]-' <"$CFG/omarchy/current/theme.name" 2>/dev/null || true; }
rm_path() { [[ -e $1 || -L $1 ]] && run rm -rf "$1" || true; }

comp_rm_theme() {
  info "Removing Morrowind themes"
  for t in morrowind morrowind-parchment; do
    [[ "$(active_theme)" == "$t" ]] && warn "'$t' is the ACTIVE theme — switch themes before/after removing it."
    rm_path "$OMARCHY_THEMES_DIR/$t"
  done
  ok "removed: morrowind, morrowind-parchment"
}

comp_rm_lockscreen() {
  info "Removing lock screen — restoring default hyprlock flow"
  rm_path "$QS_DIR/lock"
  rm_path "$BIN_DIR/rise-lock"
  rm_path "$BIN_DIR/rise-system-lock"
  remove_block "$BINDINGS" lock
  if [[ -f $HYPRIDLE ]]; then
    if [[ $DRY_RUN == 1 ]]; then
      step "[dry-run] hypridle: rise-system-lock → omarchy-system-lock + drop guard"
    else
      sed -i 's/rise-system-lock/omarchy-system-lock/g' "$HYPRIDLE"
      sed -i "s#pgrep -f 'qs .*-c lock' >/dev/null || pidof hyprlock#pidof hyprlock#" "$HYPRIDLE"
    fi
  fi
  ok "removed: lockscreen; hyprlock flow restored"
}

info "Uninstalling from ${DEST_HOME} $([[ $DRY_RUN == 1 ]] && echo '(dry-run)')"
[[ $KEEP_THEME == 0 ]] && comp_rm_theme
[[ $DO_LOCK == 1 ]] && comp_rm_lockscreen
if is_live; then
  command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 && step "hyprland reloaded"
  if [[ $DO_LOCK == 1 ]] && command -v hypridle >/dev/null; then
    pkill -x hypridle 2>/dev/null || true
    setsid hypridle >/dev/null 2>&1 < /dev/null & disown 2>/dev/null || true
    step "hypridle restarted"
  fi
fi
echo; ok "Done."

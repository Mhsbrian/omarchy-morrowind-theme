#!/usr/bin/env bash
# Installer for the Morrowind Omarchy theme.
#
#   ./install.sh [options]
#
# By default installs the Morrowind (dark) theme. Options add the extras:
#
#   --parchment         Also install the Morrowind Parchment (light) variant.
#   --with-lockscreen   Themed Quickshell lock screen. INVASIVE: replaces hyprlock
#                       as the lock command and edits ~/.config/hypr/hypridle.conf.
#   --with-visualizer   Audio spectrum strip (SUPER+M). Needs `cava`.
#   --with-launcher     Fuzzy app launcher (SUPER+Space, SUPER+D). Needs python3.
#   --with-power        Session / power menu (SUPER+Escape).
#   --with-overview     Workspace overview mini-map (SUPER+E).
#   --with-shell        All four Quickshell components above.
#   --all               Theme + parchment + lockscreen + shell components.
#   --dry-run           Print actions without changing anything.
#   -h, --help          Show this help.
#
# Tip: the base theme also installs natively with:
#   omarchy theme install https://github.com/Mhsbrian/omarchy-morrowind-theme.git
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# Theme files that live at the repo root (everything else is project scaffolding).
THEME_FILES=(colors.toml hyprland.conf hyprlock.conf mako.ini walker.css btop.theme neovim.lua icons.theme backgrounds)

DO_PARCHMENT=0 DO_LOCK=0 DO_VIZ=0 DO_LAUNCHER=0 DO_POWER=0 DO_OVERVIEW=0
usage() { sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --parchment)       DO_PARCHMENT=1 ;;
    --with-lockscreen) DO_LOCK=1 ;;
    --with-visualizer) DO_VIZ=1 ;;
    --with-launcher)   DO_LAUNCHER=1 ;;
    --with-power)      DO_POWER=1 ;;
    --with-overview)   DO_OVERVIEW=1 ;;
    --with-shell)      DO_VIZ=1; DO_LAUNCHER=1; DO_POWER=1; DO_OVERVIEW=1 ;;
    --all)             DO_PARCHMENT=1; DO_LOCK=1; DO_VIZ=1; DO_LAUNCHER=1; DO_POWER=1; DO_OVERVIEW=1 ;;
    --dry-run)         DRY_RUN=1 ;;
    -h|--help)         usage 0 ;;
    *) err "unknown argument: $1"; usage 1 ;;
  esac
  shift
done

is_live() { [[ $DRY_RUN == 0 && $DEST_HOME == "$HOME" ]]; }

comp_theme() {
  info "Morrowind (dark) theme"
  local dest="$OMARCHY_THEMES_DIR/morrowind"
  run mkdir -p "$dest"
  local f
  for f in "${THEME_FILES[@]}"; do
    [[ -e "$REPO_ROOT/$f" ]] && run cp -rT "$REPO_ROOT/$f" "$dest/$f"
  done
  ok "installed: morrowind → $dest"
}

comp_parchment() {
  info "Morrowind Parchment (light) variant"
  install_dir "$REPO_ROOT/variants/morrowind-parchment" "$OMARCHY_THEMES_DIR/morrowind-parchment"
  ok "installed: morrowind-parchment"
}

comp_lockscreen() {
  info "Themed Quickshell lock screen (invasive — replaces hyprlock)"
  install_dir  "$REPO_ROOT/extras/lockscreen/quickshell-lock" "$QS_DIR/lock"
  install_file "$REPO_ROOT/extras/lockscreen/bin/rise-lock"        "$BIN_DIR/rise-lock" 755
  install_file "$REPO_ROOT/extras/lockscreen/bin/rise-system-lock" "$BIN_DIR/rise-system-lock" 755
  append_block "$BINDINGS" lock "$(cat <<'EOF'
# Themed Quickshell lockscreen (overrides the default hyprlock binding)
unbind = SUPER CTRL, L
bindd = SUPER CTRL, L, Lock system, exec, rise-system-lock
EOF
)"
  if [[ -f $HYPRIDLE ]]; then
    backup_once "$HYPRIDLE"
    if [[ $DRY_RUN == 1 ]]; then
      step "[dry-run] hypridle: omarchy-system-lock → rise-system-lock + screensaver guard"
    else
      sed -i 's/omarchy-system-lock/rise-system-lock/g' "$HYPRIDLE"
      grep -q "qs .*-c lock" "$HYPRIDLE" || sed -i \
        "s#on-timeout = pidof hyprlock || omarchy-launch-screensaver#on-timeout = pgrep -f 'qs .*-c lock' >/dev/null || pidof hyprlock || omarchy-launch-screensaver#" \
        "$HYPRIDLE"
    fi
  else
    warn "no hypridle.conf — skipping idle-lock wiring (keybind still installed)"
  fi
  ok "installed: lockscreen; hyprlock kept as fallback"
}

# ── Quickshell components (thin wrappers around install_qs_component) ────────
comp_visualizer() {
  info "Audio visualizer (SUPER+M)"
  install_qs_component visualizer
  command -v cava >/dev/null || warn "cava is not installed — the visualizer needs it (e.g. 'omarchy pkg add cava' or 'sudo pacman -S cava')"
  ok "installed: visualizer"
}
comp_launcher() {
  info "App launcher (SUPER+Space, SUPER+D)"
  install_qs_component launcher
  command -v python3 >/dev/null || warn "python3 not found — the launcher's app scan (list-apps.py) needs it"
  ok "installed: launcher"
}
comp_power() {
  info "Session / power menu (SUPER+Escape)"
  install_qs_component power
  ok "installed: power"
}
comp_overview() {
  info "Workspace overview (SUPER+E)"
  install_qs_component overview
  ok "installed: overview"
}

info "Installing into ${DEST_HOME} $([[ $DRY_RUN == 1 ]] && echo '(dry-run)')"
comp_theme
[[ $DO_PARCHMENT == 1 ]] && comp_parchment
[[ $DO_LOCK == 1 ]] && comp_lockscreen
[[ $DO_VIZ == 1 ]] && comp_visualizer
[[ $DO_LAUNCHER == 1 ]] && comp_launcher
[[ $DO_POWER == 1 ]] && comp_power
[[ $DO_OVERVIEW == 1 ]] && comp_overview
if [[ $DO_LOCK == 1 ]]; then
  [[ ":$PATH:" == *":$BIN_DIR:"* ]] || warn "$BIN_DIR is not on \$PATH — lock scripts won't be found until it is."
fi

if is_live; then
  command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1 && step "hyprland reloaded"
  if [[ $DO_LOCK == 1 ]] && command -v hypridle >/dev/null; then
    pkill -x hypridle 2>/dev/null || true
    setsid hypridle >/dev/null 2>&1 < /dev/null & disown 2>/dev/null || true
    step "hypridle restarted"
  fi
fi

echo
ok "Done."
info "Apply with:  omarchy theme set \"Morrowind\""
[[ $DO_PARCHMENT == 1 ]] && info "        or:  omarchy theme set \"Morrowind Parchment\""
if [[ $((DO_VIZ + DO_LAUNCHER + DO_POWER + DO_OVERVIEW)) -gt 0 ]]; then
  info "Quickshell extras are live now and autostart on next login. Keybinds:"
  [[ $DO_VIZ == 1 ]]      && step "SUPER+M       audio visualizer"
  [[ $DO_LAUNCHER == 1 ]] && step "SUPER+Space   app launcher   (also SUPER+D)"
  [[ $DO_POWER == 1 ]]    && step "SUPER+Escape  power menu"
  [[ $DO_OVERVIEW == 1 ]] && step "SUPER+E       workspace overview"
fi

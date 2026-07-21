# Changelog

All notable changes to this theme are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions use [SemVer](https://semver.org/).

## [1.1.0] — 2026-07-21

### Added
- **Optional Quickshell desktop suite** as installable extras, each with a
  keybind + autostart entry and a fully reversible installer:
  - **Audio visualizer** (`SUPER+M`) — a `cava`-driven bottom-edge spectrum that,
    on Morrowind, renders as a *Telvanni living membrane*: a single luminous
    emerald ridge that ripples with the audio. Needs `cava`.
  - **App launcher** (`SUPER+Space` / `SUPER+D`) — fuzzy app search. Needs `python3`.
  - **Power menu** (`SUPER+Escape`) — lock/suspend/logout/restart/shutdown.
  - **Workspace overview** (`SUPER+E`) — mini-map of workspaces and windows.
- New install/uninstall flags: `--with-visualizer`, `--with-launcher`,
  `--with-power`, `--with-overview`, and `--with-shell` (all four). `--all` now
  also includes the suite.
- Shared `extras/quickshell/theme-fx/` shader dir, installed once and pruned on
  uninstall when no component (or the lock screen) still needs it.

### Notes
- Marker-managed keybind + autostart blocks; verified byte-for-byte clean
  uninstall against a throwaway home.

## [1.0.0] — 2026-07-20

### Added
- Morrowind (dark) Omarchy theme: full `colors.toml`, `hyprland.conf`,
  `hyprlock.conf`, `mako.ini`, `walker.css`, `btop.theme`, `neovim.lua`,
  `icons.theme`, and curated `backgrounds/`.
- Morrowind Parchment (light) variant.
- Optional themed Quickshell lock screen with reversible installer wiring.
- `install.sh` / `uninstall.sh` with `--parchment`, `--with-lockscreen`,
  `--all`, and `--dry-run`; idempotent, with marker-managed config edits and a
  verified clean uninstall.
- Documentation: install guide, customization guide, project notes.

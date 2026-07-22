# Installation guide — Morrowind

Two ways to install: Omarchy's native theme manager (fastest) or the bundled
script (needed for the Parchment variant and the optional lock screen).

---

## 1. Native install (base theme)

```bash
omarchy theme install https://github.com/Mhsbrian/omarchy-morrowind-theme.git
```

Omarchy clones the repo into `~/.config/omarchy/themes/morrowind` and applies it.
This gives you the **dark** edition. To also get the Parchment variant or the
lock screen, use the script below (you can run both — they don't conflict).

## 2. Script install

```bash
git clone https://github.com/Mhsbrian/omarchy-morrowind-theme.git
cd omarchy-morrowind-theme
./install.sh [options]
```

| Command | Installs |
|---------|----------|
| `./install.sh` | Morrowind (dark) |
| `./install.sh --parchment` | + Morrowind Parchment (light) |
| `./install.sh --with-lockscreen` | + themed lock screen |
| `./install.sh --with-notifications` | + parchment-scroll notifications (**replaces mako**) |
| `./install.sh --with-visualizer` | + audio visualizer (`SUPER+M`, needs `cava`) |
| `./install.sh --with-launcher` | + app launcher (`SUPER+Space` / `SUPER+D`, needs `python3`) |
| `./install.sh --with-power` | + power menu (`SUPER+Escape`) |
| `./install.sh --with-overview` | + workspace overview (`SUPER+E`) |
| `./install.sh --with-shell` | + all four Quickshell components above |
| `./install.sh --all` | dark + parchment + lock screen + Quickshell suite |
| `./install.sh --dry-run …` | print every action, change nothing |

Flags stack freely (e.g. `--parchment --with-visualizer --with-power`).

### Runtime dependencies

The Quickshell extras need a few packages: `quickshell` (all four), `cava` (the
visualizer), and `python` (the launcher). `install.sh` checks these up front,
prints exactly what's missing, and — with your confirmation — installs them via
`sudo pacman` (you'll be prompted for your password). Auto-confirm with `--yes`,
or manage them yourself with `--skip-deps`. The check never runs `sudo` under
`--dry-run`.

Apply a theme afterward:

```bash
omarchy theme set "Morrowind"
omarchy theme set "Morrowind Parchment"
```

### Where files go

| Component | Destination |
|-----------|-------------|
| Dark theme | `~/.config/omarchy/themes/morrowind/` |
| Parchment | `~/.config/omarchy/themes/morrowind-parchment/` |
| Lock screen | `~/.config/quickshell/lock/` |
| Lock scripts | `~/.local/bin/rise-lock`, `rise-system-lock` |
| Lock keybind | managed block in `~/.config/hypr/bindings.conf` |
| Lock idle wiring | `~/.config/hypr/hypridle.conf` (reversible) |
| Quickshell component | `~/.config/quickshell/{visualizer,launcher,power,overview}/` |
| Shared shaders | `~/.config/quickshell/theme-fx/` (installed once) |
| Component keybinds | managed blocks in `~/.config/hypr/bindings.conf` |
| Component autostart | managed blocks in `~/.config/hypr/autostart.conf` |

---

## Optional Quickshell suite

`--with-shell` (or the individual `--with-visualizer` / `--with-launcher` /
`--with-power` / `--with-overview` flags) installs standalone Quickshell
components that read the active theme's `colors.toml` and adapt.

**What each adds:** its config under `~/.config/quickshell/<name>/`, a
marker-wrapped keybind block in `bindings.conf`, and a marker-wrapped
`exec-once` line in `autostart.conf`. On the live host the component also starts
immediately. The four share `theme-fx/` (installed once).

| Component | Keybind | Overrides | Extra dependency |
|-----------|---------|-----------|------------------|
| Visualizer | `SUPER+M` | — | `cava` |
| Launcher | `SUPER+Space`, `SUPER+D` | Omarchy's `walker` | `python3` |
| Power menu | `SUPER+Escape` | Omarchy's system menu | — |
| Overview | `SUPER+E` | — | — |

Remove with `./uninstall.sh --with-shell` (or the matching individual flag);
`theme-fx/` is pruned automatically once no component or the lock screen needs it.

---

## Optional lock screen

`--with-lockscreen` replaces `hyprlock` with a themed Quickshell lock screen.

**What it changes:**
- Adds `~/.config/quickshell/lock/` and the `rise-*` scripts.
- Rebinds `SUPER+CTRL+L` (managed, marker-wrapped block).
- Edits `hypridle.conf` so idle- and before-sleep-locks use the themed lock, and
  teaches the screensaver guard to detect it. A pristine backup is written to
  `hypridle.conf.omarchy-themes.orig` before any edit.

**Safety:**
- `hyprlock` stays installed as a fallback.
- Everything is reversed exactly by `./uninstall.sh --with-lockscreen`.
- **Test it once while at your keyboard** (`SUPER+CTRL+L`, unlock with your
  password) before trusting the automatic idle lock. If a lock ever misbehaves,
  switch to a TTY (`Ctrl+Alt+F2`), run `pkill -f 'qs -c lock'`, and return with
  `Ctrl+Alt+F1`.

**Requirements:** `quickshell`, a compositor implementing `ext-session-lock-v1`
(Hyprland does), and `~/.local/bin` on your `$PATH`.

---

## Uninstall

```bash
./uninstall.sh                    # remove both editions
./uninstall.sh --with-lockscreen  # + restore default hyprlock flow
./uninstall.sh --with-shell       # + remove the Quickshell suite
./uninstall.sh --keep-theme --with-shell   # remove only the Quickshell suite
```

If you're removing the currently-applied theme, switch to another first —
Omarchy runs from a copy, so the live look lingers until you switch.

## Troubleshooting

- **`~/.local/bin is not on your $PATH`** — the lock/CRT scripts won't be found.
  Add it to your shell profile (Omarchy usually has it already).
- **Theme name not found by `omarchy theme set`** — use the display name in
  quotes: `"Morrowind"` / `"Morrowind Parchment"`.
- **Colors didn't update after editing `colors.toml`** — re-run
  `omarchy theme set "Morrowind"` to regenerate downstream app configs.

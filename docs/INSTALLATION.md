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
| `./install.sh --all` | dark + parchment + lock screen |
| `./install.sh --dry-run …` | print every action, change nothing |

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
./uninstall.sh --keep-theme --with-lockscreen   # remove only the lock screen
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

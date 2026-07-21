# Customization — Morrowind

Everything is driven by `colors.toml`. Edit it, re-apply, and the terminal, bar,
`btop`, `walker`, `mako`, `hyprlock`, and Neovim all follow.

## The palette

`colors.toml` defines an accent, cursor, fore/background, selection colors, and a
16-color terminal set (`color0`–`color15`):

```toml
accent     = "#D9B167"   # gold — bar accent, active border
foreground = "#CAA560"   # weathered gold text
background = "#14100A"   # ash-black
color1     = "#DA4F2B"   # Red-Mountain ember (red)
color2     = "#8A9A4E"   # kwama moss (green)
color3     = "#D9B167"   # gold (yellow)
# … color0–color15
```

After editing:

```bash
omarchy theme set "Morrowind"     # regenerates downstream app configs
```

## Wallpapers

Drop images into `backgrounds/` (they're picked up on install). To switch the
live wallpaper:

```bash
omarchy theme bg next             # cycle
```

Filenames are ordered (e.g. `0-…`, `10-…`); prefix to control rotation order.

## Window border & feel

`hyprland.conf` in the theme sets the active/inactive border colors and any
theme-specific animation feel. Adjust there, then `hyprctl reload`.

## Making your own variant

The Parchment edition under `variants/morrowind-parchment/` is a full theme dir
with its own `colors.toml` and a `light.mode` marker (tells Omarchy to treat it
as a light theme). Copy it, rename, tweak `colors.toml`, and install it as a new
theme:

```bash
cp -r variants/morrowind-parchment ~/.config/omarchy/themes/morrowind-dusk
$EDITOR ~/.config/omarchy/themes/morrowind-dusk/colors.toml
omarchy theme set "Morrowind Dusk"
```

## Fonts, icons

- Icons: `icons.theme` names the icon set Omarchy applies with the theme.
- Fonts are managed by Omarchy globally (`omarchy font set …`), not per-theme.

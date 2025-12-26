## Only Headshots (PAYDAY 2 / SuperBLT)

Headshot-only damage rules with optional host-only difficulty helpers.

## Features

- Enforces headshot-only damage for selected damage types.
- Optional enemy “cover head” reactions when body hits are blocked (host only).
- Optional head hitbox sphere visualization (host only), with performance controls.
- Menu settings under BLT options.

## Installation

- Requires SuperBLT (BLT v2).
- Copy the folder `Only Headshots` into your `PAYDAY 2/mods/`.

## Multiplayer / Host-only notes

- The headshot-only damage filtering is effectively host-authoritative for enemies. For consistent results in lobbies, the host should run the mod.
- “AI cover head” and “head sphere” are host-only by design.

## Settings

Open: `Options → BLT Mods → Only Headshots`

- **Enabled**: master switch.
- **Apply to**: whose attacks are filtered.
- **Exclude civilians**: do not apply the filter to civilians.
- **Strict (no hit body)**: if there is no hit body info, block the damage anyway.
- **Allow helmet/visor hits**: treat helmet/visor bodies as head hits for some enemies.
- **Allow priority weakspots**: treat some priority bodies as head hits for heavy units.
- **AI cover head (host only)**: enemies react more aggressively after blocked hits.
- **AI cover strength**: 0–100% reaction intensity/frequency.
- **AI cover panic mode**: when panic-level reactions can happen.
- **Show head sphere (host only)**: draw a sphere around the head hitbox.
- **Head sphere mode**: crosshair / nearest / all (limited).
- **Head sphere scale**: size multiplier.
- **Head sphere max distance / max units / refresh**: performance controls.
- **Include civilians**: include civilians in head sphere visualization.

## Files

- `mod.txt`: SuperBLT manifest.
- `only_headshots.lua`: core logic.
- `init.lua`: menu integration.
- `hooks/*`: runtime hooks.
- `menu/options.json`: menu definition.
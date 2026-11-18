## Why

A fresh-machine bootstrap misses most of this host's `uv tool` CLIs: only Maestral is recorded in `ubuntu.bash`, while a dozen ad-hoc installs (harness CLIs, linters, site tooling) exist solely as live state. The Maestral incident just proved the cost — reproducing its working install required rediscovering pins interactively.

## What Changes

- Inventory every `uv tool` on the host against what `ubuntu.bash` (and `scripts/install-agent-harnesses`) already records.
- Record each tool with its install spec, including `--with` constraints where the working install needs them (Maestral's `dropbox<12` + `setuptools<81` is the first entry).
- Wire the inventory into the bootstrap path so a fresh clone converges to the same toolset; decide per tool whether it belongs in `ubuntu.bash` directly or a second installer script.
- Leave tool *configuration* (auth, state, keyrings) out of scope: this change covers install reproducibility, not credential migration.

Out of scope: npm/global installs (owned by `install-agent-harnesses`), seat images, timers.

## Capabilities

### New Capabilities

- `uv-tool-inventory`: declared, reproducible `uv tool` installs on fresh bootstrap, including pinned `--with` constraints.

### Modified Capabilities

- None. No existing spec requirements change.

## Impact

- `ubuntu.bash` (and possibly a new installer script plus harness wiring).
- Host-side only: `~/.local/share/uv/tools/`, `~/.local/bin` shims. No seat, profile, timer, or relay changes.

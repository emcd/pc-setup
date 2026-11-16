## Why

The Steam snap client path for Windows games on ARM64 is broken (container provider-path abort on rev 245; rev 290 uninstallable here), while a hand-built FEX + Proton harness runs Gloomhaven with pre-existing saves intact. That harness exists only as live files under `~/Games/FEX+Proton/` and must become reproducible before it rots.

## What Changes

- Capture the `fex-proton` per-game launcher as a tracked template and deploy it via `scripts/setup-steam-arm64-gaming` (new `harness` subcommand; gaming stays opt-in and out of `ubuntu.bash` and seat images).
- Make the launcher arch-adaptive: on `x86_64` exec Proton directly; on `aarch64` run the whole Proton tree under `FEXBash` with the RootFS x86-64 Python so Wine children stay emulated.
- Record Proton payload provenance (source snapshot plus version manifest) instead of an undocumented manual copy.
- Provide a save-migration step from Steam `compatdata/<id>` prefixes into harness prefixes.
- Correct the script's stale closing checklist, which still presents the broken Steam-client UI path as the way to play.

Out of scope: full AMD64 machine setup (separate change), the Steam client/container defect itself (tracked in `pc-setup:artifacts/1` and `/2`), R&D seat images.

## Capabilities

### New Capabilities

- `fex-proton-harness`: deploy, launch, and migrate behavior of the host-side FEX + Proton per-game harness.

### Modified Capabilities

- None. No existing spec requirements change.

## Impact

- `scripts/setup-steam-arm64-gaming` gains behavior; one new tracked launcher template.
- Host-side only: `~/Games/FEX+Proton/` layout, Steam snap pieces referenced read-only, NVIDIA/DGX guard unchanged.
- No seat image, profile, timer, or relay changes.

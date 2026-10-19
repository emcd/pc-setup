## Why

Muse Code seats need a production Cistella image to run containerized like the other harnesses. The current seat profile is pinned to the shared base with a host-mounted binary, which works for trial but bypasses image pinning, checksum verification, and the refresh policy entirely.

## What Changes

- Add `images/cistella/muse/` with a codex-shaped Containerfile (fetch stage, checksum-verified platform artifact, install to `/usr/local/bin/muse`) and a pins file seeded from the `muse-stable` channel.
- Add a refresh-images discovery track for the Muse channel (`MUSE_VERSION` plus per-arch digests), with fixture tests, following the existing pin pattern.
- Flip the `muse` seat profile from `cistella/base:local` to `cistella/muse:local` once the image builds.
- Extend the `agent-images` spec scenarios to cover the Muse harness image.

## Capabilities

### New Capabilities

(none — this extends the existing image capability)

### Modified Capabilities

- `agent-images`: requirements and scenarios name the opencode and codex harness images explicitly; they must cover the muse harness image, its versioned channel artifact source, and its refresh track.

## Impact

- `images/cistella/muse/`, `scripts/refresh-images`, `scripts/test-refresh-images`, `scripts/build-image`, `scripts/validate-image`, seat profile, `openspec/specs/agent-images/spec.md` (via delta, then sync).
- No registry publishes; local tags only, per existing policy.

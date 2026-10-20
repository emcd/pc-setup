## Why

The host now runs OpenCode 2, but the seat image still ships OpenCode 1 from a GitHub release tarball. OpenCode 2 publishes no GitHub release assets, so the image cannot be bumped to the current upstream version: it needs a new artifact source, and the refresh track needs a new channel to track. Without this, seats stay on a harness major version behind the host that shares their state.

## What Changes

- **BREAKING**: Install OpenCode from the npm platform packages (`@opencode/cli-linux-arm64`, `@opencode/cli-linux-x64`) instead of a GitHub release tarball. The build keeps the same shape — fetch stage, pinned sha256 verification, one binary at `/usr/local/bin/opencode` — and still executes no install script.
- **BREAKING**: Move the OpenCode refresh track off the GitHub `releases/latest` lookup and onto the npm `latest` dist-tag of `@opencode/cli`, resolving each platform tarball from the npm registry.
- Pin the OpenCode image at 2.0.32 with per-arch sha256 pins for the npm platform tarballs.
- Update the `agent-images` spec scenario for the OpenCode artifact source.

## Capabilities

### New Capabilities

(none — this extends the existing image capability)

### Modified Capabilities

- `agent-images`: the OpenCode artifact-source scenario must name the npm platform package instead of a GitHub release tarball.

## Impact

- `images/cistella/opencode/Containerfile`, `images/cistella/opencode/pins.sh`
- `scripts/refresh-images` (OpenCode discovery track), `scripts/test-refresh-images` (fixtures)
- `README.md` (refresh policy)
- `openspec/specs/agent-images/spec.md` (via delta, then sync)
- Seats pick up the new binary when they are recreated through the coordinator. The seat mounts the host's OpenCode config and state, so the harness major version moves together on both sides and no data migration is involved.

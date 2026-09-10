# Change: Add Cistella dogfood image

## Why

Cistella dogfood currently points at `localhost/cistella/opencode:example`, a non-production example with a mutable OpenCode installer and none of the tools a real session needs. PC Setup owns production images. Cistella stays image-agnostic through `profile.image`.

## What Changes

- Add one unified Containerfile plus build and validate scripts in this repository.
- Tag the image locally as `cistella/opencode:local`.
- Pin the base digest, tool versions, and artifact checksums. Do not use mutable install scripts.
- Place binaries at user-independent paths. Do not pre-seed per-user writable state.
- Rebuild explicitly and locally. No registry publication and no Quadlet AutoUpdate in this change.
- Keep a single image. Do not extract a shared base until a second image needs it.

## Capabilities

### New Capabilities

- `agent-images`: production OCI image sources, pins, local tags, and build/validate entrypoints owned by PC Setup.

### Modified Capabilities

- None. `openspec/specs/` is empty.

## Impact

- Affected specs: new `agent-images` capability.
- Affected code: `images/cistella/opencode/**`, `data/terminfos/**`, `scripts/update-ghostty-terminfo.sh`, `scripts/build-image`, `scripts/validate-image`, README bootstrap section.
- Cistella impact: dogfood profile `image` retargets to `cistella/opencode:local` once the tag exists. No driver change. Follow-up (not in this change): ask Cistella Owner to move example pins from Bookworm to Trixie.

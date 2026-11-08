## Why

LitRPG's FE Web needs Playwright Chromium (13 X/DBus/ALSA/ATK/CUPS/GBM/Pango system libs, ~215 MB installed) for browser automation, plus the pandoc lane already carries their handbook toolchain. Baking those libs into base would tax every seat; baking them into the shared pandoc lane would tax Conlang's future use of it. A LitRPG-only child of the pandoc lane isolates the bloat to its single consumer.

## What Changes

- New `images/cistella/opencode-litrpg/` (`FROM localhost/cistella/opencode-pandoc:local` plus the 13 Playwright libraries via trixie apt; no version pins — floating apt layer, same precedent as the lane's TeX set).
- `scripts/build-image` and `scripts/validate-image` accept `opencode-litrpg` (parents-first ordering; presence assertions for the 13 tools plus inherited pandoc).
- `scripts/refresh-images` gains the sixth track (closure fingerprint over the base+opencode+pandoc chain plus own recipe; dependency-order builds; closure rollback).
- `scripts/test-refresh-images` fixture skeletons and track lists cover the new image.
- `configuration/cistella/profiles/opencode-pandoc--litrpg.toml` image line moves to `cistella/opencode-litrpg:local`. No coder changes (the `opencode--litrpg` coder already wraps that profile).

No BREAKING changes. The shared `opencode-pandoc` image and profile set are untouched (Conlang's future use stays lean).

## Capabilities

### New Capabilities

- `opencode-litrpg-image`: LitRPG-only seat image (opencode harness via the pandoc lane plus the Playwright system libraries) for browser-automation and handbook seats.

### Modified Capabilities

- `agent-images`: `scripts/build-image` and `scripts/validate-image` accept one more name (`opencode-litrpg`) with the same parents-first/closure semantics as the existing lane. No existing requirement changes behavior.

## Impact

- New image, three script wirings, one profile image-line change. Full closure rebuild once (~15 min, TeX-dominated). Seat rollout picks it up via the existing `opencode-pandoc--litrpg` profile; no bundle changes needed.

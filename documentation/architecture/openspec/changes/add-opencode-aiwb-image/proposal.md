## Why

The ai-experiments team needs Playwright-driven headless Chromium (via the playwright MCP server) in their seats. The 13 browser-runtime system libraries live in the reviewed `browser-runtime` fragment, already consumed by the litrpg final — but that final also carries the pandoc/LaTeX toolchain the ai-experiments team does not need. A lean aiwb-only final (base + opencode harness + browser libraries, no documents payload) gives them browser automation without the ~1 GB TeX tax.

## What Changes

- New `images/cistella/opencode-aiwb/` final: `FROM localhost/cistella/base:local` plus the `harness-opencode` and `browser-runtime` source fragments (same flat pattern as the reviewed finals; narrow COPY of declared fragment inputs; verified fetch stays inside the fragments).
- `scripts/build-image` and `scripts/validate-image` accept `opencode-aiwb` (independent final, no parents beyond base; library loadability + negative control assertions, same as the litrpg browser proof — no live browser execution).
- `scripts/refresh-images` gains the aiwb track (closure fingerprint over its fragment inputs; dependency-order builds; closure rollback) and `scripts/test-refresh-images` covers it.
- No profile/coder/bundle changes in this change (ai-experiments wiring lands with the requesting team once the image exists).

No BREAKING changes. All existing finals, pins, and profiles are untouched.

## Capabilities

### New Capabilities
- `opencode-aiwb-image`: ai-experiments seat image (opencode harness plus the browser-runtime system libraries, no documents payload) for playwright MCP browser automation.

### Modified Capabilities
- `agent-images`: `scripts/build-image`, `scripts/validate-image`, and `scripts/refresh-images` accept one more final name (`opencode-aiwb`) with the same flat-composition semantics as the existing independent finals. No existing requirement changes behavior.

## Impact

- New final, three script wirings, fixture coverage. One full build (~4 min, browser layer only — no TeX). Data receptacle note: `pins.sh` values, package lists, and composition lists consumed here are data, not specified behavior (see design.md for the matrix); behavior specs cover only tool boundary effects (exit codes, pin/tag/mutation effects, validation verdicts).

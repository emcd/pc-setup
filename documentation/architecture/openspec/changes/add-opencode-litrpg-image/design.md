# Design: opencode-litrpg lane-child image

## Context

The seat fleet is base -> harness (opencode/codex/muse) -> optional pandoc lane, with closure fingerprints and dependency-order rebuilds (see `add-handbook-lane-image/design.md`, whose contract this change reuses verbatim). LitRPG needs 13 Playwright system libraries (~215 MB installed) that belong to no other consumer. The `opencode-pandoc--litrpg` profile exists and its coder (`opencode--litrpg`) already wraps it; only the image it points at changes.

## Goals / Non-Goals

- Goals: a LitRPG-only fourth level (`opencode-pandoc` -> `opencode-litrpg`) carrying exactly the 13 libs; full refresh-contract participation (stale detection, ordered rebuilds, closure rollback); validated presence of the toolchain.
- Non-Goals: no new profile or coder (reuse both); no version pins for Debian packages (floating apt, lane precedent); no headless-vs-headed trimming (brittle — keep all 13); no `/dev/shm` handling in the image (MCP launch-flag `--disable-dev-shm-usage`, LitRPG side).

## Decisions

- **Child of the pandoc lane, not a sibling.** `FROM localhost/cistella/opencode-pandoc:local` keeps the handbook toolchain co-located with the browser toolchain LitRPG's workflows combine. Alternative (sibling of opencode duplicating the apt list) rejected: two copies of the 13-lib install to keep in sync.
- **Keep `opencode-pandoc` lean and available.** The shared lane image is untouched so Conlang's future use pays no Playwright tax.
- **Empty pins.sh with a comment.** No versioned inputs exist for this layer; the fingerprint covers the file plus the Containerfile plus the full parent chain, so base/opencode/pandoc drift still rebuilds it. Alternatives considered: duplicating the Debian digest pin (rejected — second drift source to track for zero gain, since the apt set already floats).
- **Presence assertions, no render gate.** `validate-image opencode-litrpg` asserts pandoc plus the 13 tool binaries; the PDF end-to-end gate stays with the lane image, and launch-chain behavior stays with LitRPG.

## Risks / Trade-offs

- [Risk] Floating apt set drifts under a fixed fingerprint → Mitigation: same as the lane's TeX set — parent digest drift rebuilds the closure, and the nightly refresh converges anything missed.
- [Risk] `strace`/`ltrace`/live-`gdb` fail without CAP_SYS_PTRACE (dropped by default) → Accepted and documented: tools degrade loudly, light up if caps are ever granted; no Cistella cap support exists today.
- [Risk] Fourth level lengthens full-closure rebuilds → Mitigation: TeX dominates build time already; the apt layer is incremental.

## Migration Plan

Build closure in dependency order, validate all six images, commit unpushed; LitRPG seats pick it up through the unchanged profile/coder on the next recreation. Rollback is recreation against `:previous` tags per the existing contract; no shared state involved.

## Open Questions

None. Bloat placement decided by Eric (lane-only); shm flag confirmed LitRPG-side.

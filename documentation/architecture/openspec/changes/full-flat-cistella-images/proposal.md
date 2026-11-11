## Why

Two capability diamonds have outgrown linear lane inheritance: the browser-runtime system libraries are needed by `opencode-aiwb` and `opencode-litrpg`, while the documents toolchain (pandoc/TeX) is needed by `opencode-conlang` and `opencode-litrpg`. A chain (`base → harness → pandoc → litrpg`) cannot express this without either taxing unrelated consumers or forking near-duplicate lanes. The operator wants one uniform construction model — composition from shared source fragments — instead of inheritance plus ad-hoc exceptions.

## What Changes

- New `images/cistella/_mixins/` source fragments (initial set: `browser-runtime`, `documents`, plus one harness fragment per supported harness), each an explicit input contract (arch/version/checksum/destination) with deterministic validation — install logic invoked from concrete lane recipes, never generated Containerfile text.
- Every final lane image is built directly `FROM` the base image with an ordered fragment list; no final lane `FROM`s another final-lane/harness tag. Private verified-artifact fetch stages inside a lane build remain allowed.
- `scripts/build-image` declares mixin sources via a named local `--build-context` per lane; no bounded-context fallback (adopting one later requires a revised proposal).
- `scripts/refresh-images` wires the source-consumer graph: fingerprint inputs extended to fragments, closure staleness per consuming lane plus image descendants, pin snapshots, rollback targets, and migration of the image graph (base → independent finals ordering, no sibling retagging).
- `scripts/validate-image` checks follow capabilities (documents rendering proof, browser-runtime proof incl. headless launch where authorized) rather than lane names alone.
- **BREAKING** (build-time only, no seat-facing change): existing intermediary lane images (`opencode`, `opencode-pandoc`, harness parents) stop being parents; old tags are left in place through migration (no automatic pruning — garbage collection stays operator-gated).

## Capabilities

### New Capabilities

- `fragment-composition`: source-fragment composition model for Cistella images — fragment input contracts, ordered per-lane composition, build-context exposure, and source-consumer closure semantics in refresh.

### Modified Capabilities

- `agent-images`: the image graph changes from linear lanes to flat finals-on-base; `build-image`, `refresh-images`, and `validate-image` accept fragments and per-lane compositions with the same closure/rollback guarantees. No seat-facing requirement changes.

## Impact

- New `_mixins/` tree, per-lane Containerfile rewrites, three script wirings plus fixture updates. Full fleet rebuild once (measured build/disk delta reported before implementation sign-off). Seat rollout unchanged (coordinator-led recreation); old intermediary tags retained until the operator gates collection.

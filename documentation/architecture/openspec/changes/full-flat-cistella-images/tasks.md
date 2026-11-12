## 1. Fragments and recipes

- [x] 1.1 Create `images/cistella/_mixins/browser-runtime/` (package list + install script + input contract) covering the 13 Playwright libraries.
- [x] 1.2 Create `images/cistella/_mixins/documents/` (pandoc verified fetch + TeX set) preserving per-arch pins and the HOLD policy.
- [x] 1.3 Create one harness fragment per supported harness (opencode, codex, muse) with fragment-direct verified fetch (D5 exception: identical URLs, strict checksums, temp cleanup, recorded payload identity).
- [x] 1.4 Rewrite each final lane Containerfile `FROM` base with an ordered fragment list via named `--build-context`; no lane-to-lane `FROM`.
- [x] 1.5 Measure the flat-vs-lane build/disk/layer delta and record it in the migration receipt before sign-off (disposition: stored-layer delta UNESTABLISHED — operator-accepted exception, Tier-1 approved; file/tar/package facts retained as scoped owner evidence, attribution claim withdrawn).

## 2. Script wiring

- [x] 2.1 Extend `scripts/build-image` with named `--build-context` mixin declaration and per-lane targets; builds MUST supply the declared local context (no image-name fallback).
- [x] 2.2 Extend `scripts/refresh-images` fingerprint inputs, target order, skip-parent semantics, pin snapshots, and rollback targets for fragments and flat finals; wire discovery fan-out so a channel bump rewrites ALL owner pin files atomically (per the D3 matrix), and extend rollback to restore every affected pin file.
- [x] 2.3 Extend `scripts/test-refresh-images` fixtures (stub lists, fingerprint-want computation) and run the suite.
- [x] 2.4 Prove independence builds with old intermediary tags absent; record the migration receipt.

## 3. Validation

- [x] 3.1 Extend `scripts/validate-image` with capability proofs (documents render, browser-runtime library-load proof with negative control) for single and union compositions. Browser execution is out of scope for libraries-only finals (no browser ships); headless execution stays deferred to an authorized browser-using consumer.
- [x] 3.2 Full closure rebuild + fleet validation green; commit pins and recipes.

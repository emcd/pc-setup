## 1. Fragments and recipes

- [ ] 1.1 Create `images/cistella/_mixins/browser-runtime/` (package list + install script + input contract) covering the 13 Playwright libraries.
- [ ] 1.2 Create `images/cistella/_mixins/documents/` (pandoc verified fetch + TeX set) preserving per-arch pins and the HOLD policy.
- [ ] 1.3 Create one harness fragment per supported harness (opencode, codex, muse) preserving verified-artifact fetch stages.
- [ ] 1.4 Rewrite each final lane Containerfile `FROM` base with an ordered fragment list via named `--build-context`; no lane-to-lane `FROM`.
- [ ] 1.5 Measure the flat-vs-lane build/disk/layer delta and record it in the migration receipt before sign-off.

## 2. Script wiring

- [ ] 2.1 Extend `scripts/build-image` with named `--build-context` mixin declaration and per-lane targets; builds MUST supply the declared local context (no image-name fallback).
- [ ] 2.2 Extend `scripts/refresh-images` fingerprint inputs, target order, skip-parent semantics, pin snapshots, and rollback targets for fragments and flat finals; wire discovery fan-out so a channel bump rewrites ALL owner pin files atomically (per the D3 matrix), and extend rollback to restore every affected pin file.
- [ ] 2.3 Extend `scripts/test-refresh-images` fixtures (stub lists, fingerprint-want computation) and run the suite.
- [ ] 2.4 Prove independence builds with old intermediary tags absent; record the migration receipt.

## 3. Validation and rollout

- [ ] 3.1 Extend `scripts/validate-image` with capability proofs (documents render, browser-runtime headless launch where authorized) for single and union compositions.
- [ ] 3.2 Full closure rebuild + fleet validation green; commit pins and recipes (push on operator word).
- [ ] 3.3 Coordinator-led seat recreation onto flat finals; old intermediary tags retained until operator-gated collection.

## Context

Post-flat tree: every final builds `FROM localhost/cistella/base:local` plus ordered source fragments via named `--build-context` mixins, with narrow COPY of declared inputs and fail-fast verified fetch inside fragments. Fragments: `harness-opencode`, `harness-codex`, `harness-muse`, `documents` (pandoc verified fetch + TeX set, PANDOC_* HOLD), `browser-runtime` (13 Playwright system libraries, trixie apt), `comfy-tools`. Consumers: `opencode`/`codex`/`muse` (harness only), `opencode-pandoc` (+documents), `opencode-litrpg` (+documents+browser+comfy). Stakeholders: ai-experiments team (requesting lane), PC Setup (image owner).

## Goals / Non-Goals

**Goals:**
- Lean aiwb final with browser automation and no TeX payload.
- Zero new mechanism: reuse reviewed fragments, scripts, and validation patterns unchanged.

**Non-Goals:**
- No new fragment, no new fetch path, no HOLD change (PANDOC_* untouched — aiwb carries no pandoc pins at all).
- No profile/coder/bundle wiring here; image-line and seat work belong to the requesting team once the image validates green.
- No TeX/pandoc evidence, no PDF proof for this final.

## Decisions

- **Compose, don't create**: `opencode-aiwb` = base + `harness-opencode` + `browser-runtime`. No new fragment because both inputs exist reviewed and unchanged; a second consumer of `browser-runtime` confirms the fragment is genuinely shared rather than litrpg-incidental.
- **Independent final, no parents beyond base**: unlike the pre-flat litrpg (child of the pandoc lane), aiwb references only `base:local`. Narrow COPY lists only its own fragment inputs; fingerprint covers exactly those inputs plus base inputs and own pins/Containerfile.
- **Validation mirrors litrpg's browser proof**: every declared browser dependency loadable via dynamic loader plus negative control; headless execution stays with an authorized consumer (playwright MCP), not the validator.
- **Non-held duplicate discipline**: aiwb's `OPENCODE_*` tuple is non-held, so version or checksum disagreement reports drift in check and repairs every owner transactionally in apply, with all-owner fan-out on channel movement. The held-Pandoc refusal exception does not apply here. Duplicate handling is explicitly enumerated for four OpenCode owners and two browser-runtime consumers — not assumed generic.
- **Data receptacle (pilot terms)**: the following are data, not specified behavior — `PANDOC_*`-free `pins.sh` for aiwb (OPENCODE_* duplicated per D3 fan-out), `browser-runtime/packages.txt` (shared, not copied), the fragment composition list in the Containerfile. Specified behavior covers only tool boundary effects (refresh exit codes, pin/tag/mutation discipline, validation verdicts). Pin-owner matrix addition: `opencode-aiwb` owns `OPENCODE_*` (duplicate, fourth owner) and consumes `browser-runtime` inputs (shared, second consumer; fragment-owned source).
- **Preservation vs extension**: all existing recipes, pin values, and profiles are preserved byte-identical. The only shared-script changes are additive track wiring (build/validate acceptance, fingerprint inputs, track ordering, rollback closure, fixture lists) — no existing lane's behavior changes.

## Risks / Trade-offs

- [Risk] Browser-library drift (floating trixie apt) breaks aiwb seats → Mitigation: fingerprints cover source package lists (not the apt repository state), so a repo-side float alone phase-shifts nothing — a source package-list edit is what stales and rebuilds; build-time breakage from float is repaired by updating the list, same precedent as litrpg.
- [Risk] Requesting team also wants comfy/pandoc later → Mitigation: additive final or fragment extension, separate change.
- [Risk] OPENCODE_* quadruple-duplication (now four owners) widens the B3 class → Mitigation: the divergent-duplicate agreement check is explicitly extended to enumerate all four owners with version plus both checksums, same-version repair, and transactional all-owner fan-out.

## Migration Plan

Build + validate green, refresh check converged, fixtures extended; seat rollout with the ai-experiments team on operator word. Rollback: image tag only (`:previous`), no data migration.

## Open Questions

- Profile/coder ownership for aiwb seats (requesting team or pc-setup provisioned mounts?) — deferred to rollout, not this change.
- Lightweight data-review path for pattern-following lanes (process note for the Tier-1 packet, not decided here).

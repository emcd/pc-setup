## Context

Cistella images are linear lanes: `base → harness → opencode-pandoc → opencode-litrpg`. Two capability diamonds no longer fit: browser-runtime libraries serve `aiwb` + `litrpg`, documents toolchain serves `conlang` + `litrpg`. The operator requires one uniform construction model (composition from shared source fragments, no inheritance between final images) rather than inheritance plus exceptions. Prior art: `opencode-litrpg` already proves the pandoc+browser union composes; `refresh-images` already reconciles pins→images via closure fingerprints, dependency-order builds, and tag rollback. Advisor consultation (Tier-2) approves full-flat as viable with explicit constraints, recorded here as decisions.

## Goals / Non-Goals

**Goals:**
- Every final image builds directly `FROM` the base image with an explicit ordered fragment list; no final lane `FROM`s another final/harness tag.
- One composition mechanism for capabilities and harnesses alike; per-lane recipes stay ordinary Containerfiles (explicit `ARG/ENV/COPY/RUN`, no generator).
- Refresh closure covers fragments precisely: mixin edit stales direct consumers plus image descendants, never siblings/ancestors.
- Capability validation follows capabilities (documents proof, browser-runtime proof), not lane names.
- Measured build/disk/layer delta reported before implementation sign-off.

**Non-Goals:**
- No template/generation engine (no Jinja/m4 synthesis of Containerfile instructions, stages, or metadata).
- No new lane images in this change (`opencode-aiwb`, `opencode-conlang` are follow-up consumers of the fragments).
- No pruning of old intermediary tags (garbage collection stays operator-gated); no seat rollout changes; no timer changes.

## Decisions

**D1. Fragments are source-only, invoked from concrete recipes.**
Each mixin is a directory `images/cistella/_mixins/<name>/` holding a package list, an install script with an explicit input contract (arch/version/checksum/destination), and deterministic validation with typed refusal. Lanes `COPY` fragment sources and `RUN` them in a fixed declared order. Rejected: cross-image `COPY --from=<mixin-image>` of installed OS payloads (dpkg/state skew); generating instruction text (templating territory — see boundary below).

**D2. Build context is named-only.**
`build-image` uses each lane directory as its context, so sibling `_mixins/` is invisible to plain `COPY`. Lanes declare `--build-context mixins=<relpath>/_mixins` and use `COPY --from=mixins <name>/…`. Podman 4.9.3 supports local named contexts (remote clients do not — we are local rootless, so acceptable). Rejected alternative: a bounded `images/cistella` context with ignore policy — equivalent only with its ignore policy and every actually-consumed input fingerprinted and preflighted, and adopting it later requires a revised proposal. Never `COPY` the repo root; never generate untracked recipe files outside the fingerprint. Implementation MUST supply the declared local context on every build rather than accidentally relying on image-name fallback.

**D3. Pin ownership stays with the final lane, duplicated with atomic fan-out.**
The final lane's `pins.sh` declares every pin its composition consumes; shared channel pins (harness versions and checksums) are duplicated into each consuming final rather than inherited. Fragments accept versions as build `ARG`s and SHALL NOT look up ambient pins. Refresh discovery keeps one writer, but that writer owns multiple target files: a channel update rewrites ALL owner files atomically before fingerprinting, and rollback restores every affected pin file. Pandoc's per-arch verified fetch and HOLD policy move unchanged into the documents fragment interface and stay notify-only across consumers. Current composition / pin-owner matrix (base pins shared; everything else final-owned):

| Final | Composition | Pin owners (final-owned unless noted) |
|---|---|---|
| `opencode` | harness fragment | `OPENCODE_*` (own) |
| `codex` | harness fragment | `CODEX_*` (own) |
| `muse` | harness fragment | `MUSE_*` (own) |
| `opencode-pandoc` | documents fragment (+ harness) | `OPENCODE_*` (dup), `PANDOC_*` (own, held) |
| `opencode-litrpg` | documents + browser-runtime + comfy tools (+ harness) | `OPENCODE_*` (dup), `PANDOC_*` (dup, held), `COMFY_MCP/COMFY_CLI_*` (own), Playwright libs float on trixie apt (no pins, TeX precedent) |

Base pins (`DEBIAN_IMAGE`, `RUST_IMAGE`, cargo/uv/gh toolchain pins) remain shared and are unaffected. An OpenCode channel bump therefore stales every OpenCode-consuming final and no codex/muse final; a lane-only pin stales only its consumer.

**D4. Templating boundary is explicit.**
Parameters (versions, arch switches via `TARGETARCH`, bounded flags) do NOT constitute templating. The boundary is crossed if and only if the change needs to synthesize Containerfile instructions, allocate stages, merge image metadata (`ENV/USER/WORKDIR/ENTRYPOINT/CMD/LABEL`), or interpret a free-form fragment list at build time — that machinery must then be named, versioned, fingerprinted, and reviewed as a composition engine. A runtime dispatcher is equally machinery. None is introduced here.

**D5. Fetch stages are allowed; fragment-direct verified fetch is approved.**
"Zero intermediaries" means no `FROM` on another final-lane tag. Private verified-artifact fetch stages inside a lane build remain allowed and are the default conservative shape. As an explicit approved alternative, a fragment install script MAY perform the verified fetch directly in the final stage when it preserves the full verified-fetch semantics: identical pinned URLs, `sha256sum --check --strict` verification before use, temp download/extract cleanup leaving no residue in the final layer, and the installed payload's identity recorded in the migration receipt (byte-identical shas). No image-name fallback, no copied rootfs payloads, no dpkg-state grafting. The current implementation uses the fragment-direct form for all five lanes (single definition per payload instead of triplicated inline fetch stages); reintroducing per-lane fetch stages remains available without a design change if a future payload cannot meet the bar.

**D6. Migration proves independence.**
Flat finals must build with old intermediary `:local` tags absent (base present, harness/pandoc tags removed). Refresh order becomes base → independent finals; skip-parent semantics reconciled so nothing retags siblings. Old tags are left in place through migration for rollback.

## Risks / Trade-offs

- [Risk] Mutable apt feeds: equal recipe hash ≠ identical installed versions across build times → Mitigation: record resolved dpkg versions plus standalone-binary pins in the per-build receipt; validate exact faces/tools, not just recipe equality.
- [Risk] Layer/disk/build duplication vs shared parents → Mitigation: measured delta (image IDs, layer counts, build times, shared-vs-unique accounting) required before sign-off; no capacity claims without numbers. Note harnesses are prebuilt fetches and cargo stays in shared base, so the delta is TeX/apt + lane tools, not a compiler workload.
- [Risk] `--no-cache` refresh plus differing preceding steps yield non-identical layers → Mitigation: no byte-identity claim for the structural rebuild; every content/behavior difference gets a stated explanation in the migration receipt.
- [Risk] Refresh lock does not freeze source edits → Mitigation: state the stable-input assumption (hash and build read the same frozen files); document, don't re-architect locking in this change.
- [Risk] Fragment edit over/under-stales → Mitigation: explicit consumer lists per fragment, tested by closure-precision scenarios; missing declared inputs fail preflight before tags move.

## Migration Plan

1. Land fragments + flat lane recipes alongside (no tag moves); prove independence builds with old tags absent.
2. `refresh-images --apply` reconciles pins and rebuilds base → independent finals; validate per capability.
3. Commit pins + recipes; push on operator word; seats pick up via coordinator-led recreation.
4. Rollback: `refresh-images --rollback` restores preserved tags; recipes/fragments stay desired-and-stale so a later check still reports stale and a retry converges. Old intermediary tags are never auto-deleted.

## Open Questions

- Measured delta acceptance threshold: what build-time/disk regression (if any) the operator accepts for uniformity — answered with numbers from step 1, not in advance.
- Whether `opencode-aiwb` / `opencode-conlang` lane creation follows immediately as consumers or waits — decided at proposal acceptance: new lanes are created AFTER the proposal is implemented, as separate follow-up changes.

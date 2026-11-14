## 1. Final recipe

- [x] 1.1 Create `images/cistella/opencode-aiwb/` (pins.sh with D3-duplicated `OPENCODE_*`, Containerfile `FROM` base + harness-opencode + browser-runtime fragments with narrow COPY of declared inputs).
- [x] 1.2 Record the pin-owner matrix addition in design.md if the composition differs from this plan.

## 2. Script wiring

- [x] 2.1 Extend `scripts/build-image` and `scripts/validate-image` to accept `opencode-aiwb` (independent final; library loadability + negative control, no browser launch).
- [x] 2.2 Extend `scripts/refresh-images` fingerprint inputs (including base inputs), snapshot/restore lists, preflight, stale/build/validation and rollback lists for `opencode-aiwb`; extend explicit OPENCODE owner fan-out and same-version repair to enumerate all four owners.
- [x] 2.3 Extend `scripts/test-refresh-images` skeletons, seed lists, and track lists; cover closure precision (shared edit stales litrpg+aiwb, lane-only edit stales aiwb alone), all-owner channel fan-out, divergent aiwb duplicate check-drift and apply-repair, write failure during writes and after an earlier consumer succeeds, and the absent-tag bootstrap disposition (first standalone build/validation before refresh manages the lane).

## 3. Validation and review

- [x] 3.1 Build + validate `opencode-aiwb` green (image `24ebb800e5d9`); hermetic absence fixtures 4/4; full refresh suite 91/91 green. Refresh check classifies correctly (aiwb stale pre-convergence, upstream drift reported, no errors).
- [ ] 3.3 Converge `opencode-aiwb` refresh labels on the next timer apply (with the pending upstream drift then due); check-only evidence above does not claim convergence.
- [ ] 3.2 Tier-1 implementation review, then Tier-2; include the lightweight data-review process note in the packet.

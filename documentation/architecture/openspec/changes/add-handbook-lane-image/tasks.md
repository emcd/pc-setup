## 1. Base font stack

- [x] 1.1 Add `fontconfig` and `fonts-dejavu-core` to the base final-stage apt install list
- [x] 1.2 Extend `scripts/validate-image` discovery checks to cover `fc-list` with DejaVu Sans and DejaVu Sans Mono (same change, per the distro-baseline rule)

## 2. Handbook lane image track

- [x] 2.1 Create `images/cistella/opencode-pandoc/Containerfile` (`FROM localhost/cistella/opencode:local`, pandoc 3.1.13 per-arch tarball with sha256 check, trixie texlive-xetex + texlive-latex-recommended + texlive-fonts-recommended + texlive-latex-extra + lmodern, poppler-utils, fontconfig, fonts-dejavu-core, no fonts-extra)
- [x] 2.2 Create `images/cistella/opencode-pandoc/pins.sh` (PANDOC_VERSION + per-arch sha256)
- [x] 2.3 Create `configuration/cistella/profiles/opencode-pandoc.toml` (lane image, standard seat mounts and environment, standalone default command)
- [x] 2.4 Accept `opencode-pandoc` in `scripts/build-image` (build base, then opencode, then the lane image; parents from cache, `--no-cache` for the named image only; `--skip-parents` for callers that converged the parents already) and in `scripts/validate-image` (pandoc version, end-to-end rendered-content check, base-inherited checks)
- [x] 2.5 Cover the pandoc pin in `scripts/refresh-images` drift detection as HELD (notify-only with a `hold_reason` naming the 3.1-series policy, reported on ANY newer stable upstream within or above the series, never bumped) and in `scripts/test-refresh-images` fixtures, including cases asserting the held pin is NOT bumped on within-series drift and on above-series drift
- [x] 2.6 Extend the refresh fingerprint to the closure (own pins + own Containerfile + every ancestor's pins + Containerfile) for every track; build in dependency order (base, opencode, lane); rebuild descendants on inherited drift even when held; snapshot, preserve, restore, and rollback the affected closure including the lane track
- [x] 2.7 Add fixture cases: missing-parent lane build fails; opencode-only change rebuilds opencode + lane; base-only change rebuilds base + opencode + lane (one bootstrap round converges the new hashes); held-only drift reports without work; child validation failure restores the full closure

## 3. Validate and roll out

- [x] 3.1 Rebuild base, opencode, and the lane image `--no-cache`; verify `pandoc --version` reports 3.1.13, `opencode --version` reports the pinned version, and a representative handbook document builds end to end with the lane's exact invocation; assert `pdftotext` output contains the em-dash, arrow, and TOC entries with every PDF font embedded; record measured image sizes and package/font versions with the built digests
- [x] 3.2 Run the full fixture suite green plus shellcheck
- [ ] 3.3 Commit the change; rollout is lane-seat recreation through the coordinator against the lane profile (LitRPG re-validates handbook output at rollout; exact-3.1.3 fallback pre-agreed on content diffs)

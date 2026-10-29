## Why

The LitRPG team's handbook lane migrated to Cistella seats and cannot produce its PDF output: the seat images ship no document toolchain (no pandoc, no TeX engine, no PDF utilities) and no fonts at all, without which no PDF engine runs. Their maps lane additionally vendors fonts in-repo as a workaround for deterministic SVG-to-PNG rendering. Both lanes are holding off workaround patches pending a first-party answer.

## What Changes

- Add a shared `opencode-pandoc` seat image, `FROM localhost/cistella/opencode:local`, carrying the document toolchain: pandoc 3.1.13 (latest 3.1.x, pinned upstream tarball, per-arch sha256), texlive-xetex + texlive-latex-recommended + texlive-fonts-recommended + texlive-latex-extra + lmodern (Debian trixie packages), poppler-utils, fontconfig, and fonts-dejavu-core (standardized font set: DejaVu Sans + Sans Mono). The harness comes from the base opencode image layer; the lane layer adds only the toolchain. The handbook lane validated 3.1.3 output; both teams accept latest-3.1.x, with re-validation against the new pin at rollout.
- Add fontconfig + fonts-dejavu-core to the shared `base` image so every seat (including the maps lane on the standard images) has a working font stack and the vendored-fonts workaround can be removed. No TeX engine and no pandoc in base: the ~560 MB document toolchain (measured lane-over-opencode delta) stays confined to the lane image.
- Cover the new image with the existing refresh, validation, and fixture machinery (pins file, `--no-cache` rebuild path, `validate-image`, refresh-track drift detection for the pandoc pin).
- Explicitly not included: texlive-fonts-extra (~1.7 GB). The handbook's actual character set (Latin script, em-dashes, smart quotes, ligatures) is covered by DejaVu/Latin Modern; the requesting lane confirmed it is not needed.
- Fleet-wide refresh change in the same proposal: staleness compares pins *and* Containerfile bytes across each image's closure with parents-first build order and closure rollback (every existing track reads stale once and converges in a bootstrap rebuild round); validation gains a rendered-content check; reproducibility is the validated built digest with recorded versions, not identical output on rebuild.

## Capabilities

### New Capabilities
- `opencode-pandoc-image`: shared document-toolchain seat image variant (opencode harness plus the pinned pandoc/TeX/PDF/font toolchain) for handbook-generating seats, plus its seat profile. First consumers: LitRPG handbook and maps lanes; anticipated second consumer: Conlang's deferred PDF work.

### Modified Capabilities
- `agent-images`: base image gains a font stack (fontconfig + DejaVu); the refresh, validation, and rollback contract changes for every track, not just the new one — staleness compares pins *and* Containerfile bytes across each image's closure, parents build before children in dependency order, and rollback restores the affected closure. Every existing track reads stale once and converges in a single documented bootstrap rebuild round.

## Impact

- `images/cistella/opencode-pandoc/` (new Containerfile + pins.sh, lane layer over the opencode image); `configuration/cistella/profiles/opencode-pandoc.toml` (lane seat profile); `images/cistella/base/Containerfile` (+2 apt packages); `scripts/refresh-images` (new track, closure fingerprinting, dependency-order builds, closure rollback), `scripts/build-image` (parents-first ordering for the new target), `scripts/validate-image` (new target including rendered-content check), `scripts/test-refresh-images` (new track + closure fixtures); `README.md` (lane image documented alongside the fleet images).
- Fleet-wide one-time effect: the fingerprint-semantics change makes every existing track stale once; all images converge in a single documented bootstrap rebuild round as part of rollout.
- Validation now includes a rendered-content check (`pdftotext` glyph/TOC + missing-glyph-warning inspection), and reproducibility is the validated built digest with recorded versions -- not identical output on rebuild.
- Image size: base grows ~5 MB installed; the lane image adds ~560 MB (measured; TeX tree dominates) on top of base — paid only by handbook-lane seats.
- Requesting lane: LitRPG handbook (PDF) + maps (fonts); no changes required on their side beyond consuming the images once rolled out.

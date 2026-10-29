## ADDED Requirements

### Requirement: Lane image carries the pinned document toolchain over the opencode image
The handbook lane image SHALL start `FROM localhost/cistella/opencode:local` and SHALL add pandoc 3.1.13 installed from the per-arch upstream release tarball whose sha256 matches the pin, plus the trixie packages `texlive-xetex`, `texlive-latex-recommended`, `texlive-fonts-recommended`, `texlive-latex-extra`, `lmodern`, `poppler-utils`, `fontconfig`, and `fonts-dejavu-core`. It SHALL NOT contain texlive-fonts-extra. The opencode harness binary SHALL come from the base opencode layer, not from a reinstall.

#### Scenario: Pandoc version pinned
- **WHEN** `podman run --rm` executes `pandoc --version` in the handbook image
- **THEN** the output reports pandoc 3.1.13

#### Scenario: Opencode harness present from the base layer
- **WHEN** `podman run --rm` executes `opencode --version` in the handbook image
- **THEN** the output reports the pinned opencode version

#### Scenario: Representative handbook document builds end to end
- **WHEN** a representative markdown document (heading, table, em-dash, arrow, TOC depth 2) is built with the lane's exact invocation (`pandoc input.md -o output.pdf --toc --toc-depth=2 --pdf-engine=xelatex`)
- **THEN** a PDF is produced, exercising the full default-template dependency chain rather than a fixed package list

#### Scenario: Rendered content is extracted, not just produced
- **WHEN** `pdftotext` extracts the built PDF and `pdffonts` lists its fonts
- **THEN** the extracted text contains the em-dash and the arrow and the TOC entries, and every listed font shows `emb` as `yes` (no unembedded fallback that would signal a missing glyph)

#### Scenario: TeX and PDF tools present
- **WHEN** `podman run --rm` executes `xelatex --version`, `pdftotext -v`, and `fc-list` in the handbook image
- **THEN** each succeeds and `fc-list` lists DejaVu Sans and DejaVu Sans Mono

#### Scenario: No fonts-extra payload
- **WHEN** the handbook image is built
- **THEN** no `texlive-fonts-extra` package content is installed

### Requirement: Reproducibility is the validated built image, not the pins
The reproducibility guarantee is the validated built image digest, with the resolved package and font versions and the parent image digests recorded alongside it. Identical pins SHALL NOT be taken to promise identical PDF output on a later rebuild, because `apt-get update` resolves current repository indices independently of the base image digest. No Debian snapshot is introduced by this change.

#### Scenario: Rebuild picks up newer apt state
- **WHEN** the lane image is rebuilt later from identical pins
- **THEN** newer trixie package revisions may be installed, and identical PDF output is not promised

### Requirement: Lane image joins the refresh contract as a held pin
The handbook image SHALL have a pins file following the existing track shape (version plus per-arch sha256). Refresh drift detection SHALL cover its pandoc pin as HELD (notify-only): drift is reported every run but the pin is never bumped and never triggers a rebuild, with a `hold_reason` naming the 3.1-series policy. `scripts/build-image` and `scripts/validate-image` SHALL accept `opencode-pandoc`, and the fixture suite SHALL cover the new track including a case asserting the held pin is not bumped when a newer upstream release exists.

#### Scenario: Held drift is reported, not applied
- **WHEN** a newer stable upstream pandoc release exists, within or above the 3.1 series
- **THEN** `scripts/refresh-images check` reports handbook pin drift, and `scripts/refresh-images` apply leaves the pin untouched

### Requirement: Lane image builds after its parents in dependency order
`scripts/build-image opencode-pandoc` SHALL build base, then opencode, then the lane image (parents from cache in standalone mode, `--no-cache` applying to the named image only). Refresh SHALL build in dependency order and pass `--skip-parents` for the lane build, since it converged the parents itself; an unlabeled intermediate parent retag SHALL NOT clobber a converged refresh label. A rebuild of opencode or base SHALL rebuild the lane image even when the pandoc pin is HELD and unchanged; held drift alone SHALL NOT trigger any rebuild.

#### Scenario: Opencode-only change rebuilds the lane image
- **WHEN** the opencode pins change while the pandoc pins and recipe are unchanged
- **THEN** refresh rebuilds opencode and the lane image, and validates both

#### Scenario: Base-only change rebuilds the lane image
- **WHEN** the base pins or base recipe change while opencode and pandoc inputs are unchanged
- **THEN** refresh rebuilds base, opencode, and the lane image, and validates each

#### Scenario: Held-only drift does no work
- **WHEN** only newer upstream pandoc releases exist and every image label matches its effective fingerprint
- **THEN** refresh reports the held drift and rebuilds nothing

#### Scenario: Missing parent fails the lane build
- **WHEN** `scripts/build-image opencode-pandoc` runs without a local opencode image to layer on
- **THEN** the build fails rather than tagging a lane image over a missing or implicitly pulled parent

### Requirement: Effective fingerprint covers the closure including recipe content
Each image's effective fingerprint SHALL hash its own pins file and its own Containerfile plus every ancestor's pins file and Containerfile (lane: base pins + base recipe + opencode pins + opencode recipe + lane pins + lane recipe). A recipe-only change with unchanged pins SHALL mark the image and all its descendants stale. The one-time consequence is a single documented bootstrap rebuild round converging all tracks to the new hashes.

#### Scenario: Recipe-only base change marks descendants stale
- **WHEN** the base Containerfile changes with base pins unchanged
- **THEN** refresh marks base, opencode, and the lane image stale and rebuilds all three

### Requirement: Rollback restores the affected closure
Refresh failure and explicit rollback SHALL restore the affected closure's pin bytes and `:previous` tags (pins and images agree afterwards, both new on success and both old on failure), including the lane track's pins and tags.

#### Scenario: Child validation failure restores everything
- **WHEN** the lane image fails validation after its parents rebuilt successfully
- **THEN** lane, opencode, and base pins and `:previous` tags are restored and no partially new closure remains tagged `:local`

#### Scenario: Lane image validates
- **WHEN** `scripts/validate-image opencode-pandoc` runs after a successful handbook build
- **THEN** the pandoc version, TeX/PDF/font discovery, and base-inherited checks pass

### Requirement: Lane seat profile wires the lane image
A `opencode-pandoc` Cistella profile SHALL name the lane image and SHALL carry the standard seat mounts, environment acceptances, and the standalone default command. Handbook-lane seats SHALL launch against this profile.

#### Scenario: Lane profile resolves the lane image
- **WHEN** `cistella conduct --profile opencode-pandoc` resolves its image
- **THEN** it selects `cistella/opencode-pandoc:local`

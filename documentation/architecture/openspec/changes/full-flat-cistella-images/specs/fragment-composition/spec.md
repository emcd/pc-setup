## ADDED Requirements

### Requirement: Source-only install fragments
Each mixin SHALL live at `images/cistella/_mixins/<name>/` as an explicit input contract (arch, version, checksum, destination file list) with deterministic validation and typed refusal. Fragments SHALL be invoked from concrete lane recipes and SHALL NOT generate Containerfile instructions, stages, or image metadata.

#### Scenario: Fragment layout is explicit
- **WHEN** a lane consumes a mixin
- **THEN** the lane recipe names the mixin and its ordered position, and all fragment inputs are files under that mixin's directory

#### Scenario: Instruction generation is out of scope
- **WHEN** a composition need requires synthesizing Containerfile instructions, allocating stages, or merging image metadata
- **THEN** it is rejected as a fragment and must be proposed as an explicit composition engine instead

### Requirement: Named build-context exposure
Lanes SHALL declare mixin sources via a named local `--build-context` and consume them with `COPY --from=<context>`. The build SHALL NOT `COPY` the repo root and SHALL NOT generate untracked recipe files outside the fingerprint.

#### Scenario: Mixin files visible without repo-root copy
- **WHEN** a lane build runs
- **THEN** mixin sources resolve through the declared named context and the build context excludes unrelated trees

#### Scenario: Declared local context is always supplied
- **WHEN** a lane build invokes a mixin copy
- **THEN** the build supplies the declared local named context rather than relying on image-name fallback when the flag is absent

### Requirement: Pin ownership by the final lane
The final lane's `pins.sh` SHALL declare every pin its composition consumes, duplicating shared channel pins (harness versions and checksums) into each consuming final rather than inheriting them; fragments SHALL accept versions as build `ARG`s and SHALL NOT look up ambient pins. Refresh discovery SHALL write all owner files for a channel atomically before fingerprinting. Pandoc's per-arch verified fetch and HOLD policy SHALL be preserved through the documents fragment interface and SHALL stay notify-only across all consumers. Existing lane-owned tool pins (notably the litrpg `COMFY_MCP_VERSION` / `COMFY_CLI_VERSION` tooling) are preserved as lane-owned pins.

#### Scenario: No ambient pin lookup
- **WHEN** a fragment installs its payload
- **THEN** all versions and checksums arrive via explicit build arguments declared in the owning lane's pins

#### Scenario: Shared channel bump fans out to all consumers
- **WHEN** the OpenCode channel publishes a new version
- **THEN** discovery updates every OpenCode-consuming final's pins and rebuilds each of them, while codex and muse finals remain converged

#### Scenario: Lane-only pin affects only its consumer
- **WHEN** a pin consumed by exactly one final changes
- **THEN** only that final goes stale and no sibling rebuilds

#### Scenario: Pandoc hold survives the move
- **WHEN** the documents fragment is consumed
- **THEN** pandoc stays notify-only and is never auto-bumped by discovery

#### Scenario: Partial failure restores every affected pin file
- **WHEN** a later consumer fails after discovery rewrote several owners
- **THEN** all affected lane pin bytes are restored alongside all preserved tags

### Requirement: Source-consumer closure staleness
A mixin edit SHALL stale its direct consumers plus their image descendants, and SHALL NOT stale unrelated siblings or ancestors. A missing declared fragment input SHALL fail preflight before any tag moves. Composition membership or order changes SHALL stale the affected final.

#### Scenario: Precision staleness
- **WHEN** the browser-runtime fragment changes
- **THEN** its consumers and their descendants are stale while unrelated lanes remain converged

#### Scenario: Missing input fails fast
- **WHEN** a lane declares a fragment input that does not exist
- **THEN** refresh fails before moving any tag

### Requirement: Flat finals with private stages allowed
Every final lane image SHALL start `FROM` the base image and SHALL NOT `FROM` another final-lane or harness tag. Private verified-artifact fetch stages inside a lane build remain allowed and SHALL leave no download or build-tool residue in the final image.

#### Scenario: No lane-to-lane FROM
- **WHEN** a final lane recipe is inspected
- **THEN** its only image reference is the base tag plus its own private stages

### Requirement: Migration independence proof
Flat finals SHALL build with old intermediary `:local` tags absent and only the base tag present. Refresh order SHALL be base first, then independent finals, with no sibling retagging. Old intermediary tags SHALL NOT be auto-deleted.

#### Scenario: Independence build
- **WHEN** a flat final builds while old harness and pandoc tags are absent
- **THEN** the build succeeds from declared inputs alone

### Requirement: Rollback restores affected closure
A failure after one or more flat consumers build or validate SHALL restore all preserved affected tags and pin bytes, including previously successful consumers. Source fragments SHALL remain desired-and-stale after rollback so a later check still reports stale and a retry converges. Lanes with no prior tag need an explicit bootstrap disposition.

#### Scenario: Partial failure restores all
- **WHEN** a later consumer fails after an earlier consumer validated
- **THEN** all preserved tags and pins are restored and a subsequent check reports the work as still pending

### Requirement: Capability validation per composition
Validation SHALL prove claimed capabilities per final: documents rendering proof where documents are claimed, browser-runtime proof (bounded headless launch against local fixture content where live proof is authorized) where browser use is claimed, plus lane extras. Package presence alone SHALL NOT count as proof, and browser libraries SHALL NOT imply new sockets, devices, network exposure, or sandbox exemptions.

#### Scenario: Union proves both
- **WHEN** a composed final claims documents and browser-runtime
- **THEN** validation executes both proofs, not merely presence checks

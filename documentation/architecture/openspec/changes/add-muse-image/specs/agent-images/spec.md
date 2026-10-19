# agent-images delta (add-muse-image)

## MODIFIED Requirements

### Requirement: Shared base and thin harness images
PC Setup SHALL publish a shared local image `cistella/base:local` that contains the seat toolchain and SHALL NOT contain a harness binary. Each harness image SHALL start `FROM localhost/cistella/base:local` and SHALL add only its harness binary. A harness pin change SHALL NOT rebuild the shared base.

#### Scenario: Base has no harness binary
- **WHEN** `scripts/validate-image base` runs
- **THEN** shared seat tools are present and `opencode`, `codex`, and `muse` are absent

#### Scenario: Harness image adds only its binary
- **WHEN** `scripts/build-image opencode`, `scripts/build-image codex`, or `scripts/build-image muse` succeeds
- **THEN** the harness image contains that harness binary and the shared seat tools from the local base tag

### Requirement: Verified version-pinned artifacts
Each production image SHALL pin third-party tool versions and artifact checksums or lockfiles. The build SHALL NOT execute mutable install scripts (including `https://opencode.ai/install`, `https://chatgpt.com/codex/install.sh`, and `https://dev.meta.ai/install.sh`). The build SHALL fail if a checksum or lock does not match.

#### Scenario: OpenCode comes from a versioned artifact
- **WHEN** the OpenCode image is built
- **THEN** OpenCode is installed from a versioned GitHub release tarball whose checksum matches the pin

#### Scenario: Codex comes from a versioned artifact
- **WHEN** the Codex image is built
- **THEN** Codex is installed from a versioned GitHub release tarball whose checksum matches the pin, and the archive member is installed as `/usr/local/bin/codex`

#### Scenario: Muse comes from a versioned artifact
- **WHEN** the Muse image is built
- **THEN** Muse is installed from the versioned `muse-stable` channel manifest artifact whose checksum matches the pin, installed as `/usr/local/bin/muse`

#### Scenario: Checksum mismatch fails the build
- **WHEN** a pinned artifact checksum does not match the downloaded bytes
- **THEN** the build fails and does not tag the image under construction

### Requirement: Local tag and explicit rebuild
`scripts/build-image` SHALL accept `base`, `opencode`, `codex`, or `muse`. With no image name it SHALL build the shared base and tag `cistella/opencode:local`. A named harness build SHALL rebuild the shared base from cache first, then tag `cistella/<name>:local`. `--no-cache` SHALL apply only to the named image. `scripts/validate-image` SHALL accept the same names and, with no name, check `cistella/opencode:local`. Rebuild SHALL be an explicit local `podman build`. The change SHALL NOT publish to a registry or configure Quadlet AutoUpdate.

#### Scenario: Build tags the local image
- **WHEN** `scripts/build-image` succeeds
- **THEN** `podman image exists cistella/opencode:local`

#### Scenario: Validate checks the tagged image
- **WHEN** `scripts/validate-image` runs after a successful OpenCode build
- **THEN** the baked-terminfo, layout, version-pin, and tmux checks pass

#### Scenario: Codex build tags its own image
- **WHEN** `scripts/build-image codex` succeeds
- **THEN** `podman image exists cistella/codex:local`

#### Scenario: Muse build tags its own image
- **WHEN** `scripts/build-image muse` succeeds
- **THEN** `podman image exists cistella/muse:local`

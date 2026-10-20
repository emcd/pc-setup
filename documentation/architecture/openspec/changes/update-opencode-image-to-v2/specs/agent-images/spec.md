# agent-images delta (update-opencode-image-to-v2)

## MODIFIED Requirements

### Requirement: Verified version-pinned artifacts
Each production image SHALL pin third-party tool versions and artifact checksums or lockfiles. The build SHALL NOT execute mutable install scripts (including `https://opencode.ai/install`, `https://chatgpt.com/codex/install.sh`, and `https://dev.meta.ai/install.sh`). The build SHALL fail if a checksum or lock does not match.

#### Scenario: OpenCode comes from a versioned artifact
- **WHEN** the OpenCode image is built
- **THEN** OpenCode is installed from a versioned npm platform package tarball whose checksum matches the pin, and the archive member is installed as `/usr/local/bin/opencode`

#### Scenario: Codex comes from a versioned artifact
- **WHEN** the Codex image is built
- **THEN** Codex is installed from a versioned GitHub release tarball whose checksum matches the pin, and the archive member is installed as `/usr/local/bin/codex`

#### Scenario: Muse comes from a versioned artifact
- **WHEN** the Muse image is built
- **THEN** Muse is installed from the versioned `muse-stable` channel manifest artifact whose checksum matches the pin, installed as `/usr/local/bin/muse`

#### Scenario: Checksum mismatch fails the build
- **WHEN** a pinned artifact checksum does not match the downloaded bytes
- **THEN** the build fails and does not tag the image under construction

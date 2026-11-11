## MODIFIED Requirements

### Requirement: Shared base and thin harness images
PC Setup SHALL publish a shared local image `cistella/base:local` that contains the seat toolchain and SHALL NOT contain a harness binary. Each final image SHALL start `FROM localhost/cistella/base:local` and SHALL add its capabilities only through explicitly declared source fragments in a fixed order; no final image SHALL `FROM` another final image. A pin change in one lane SHALL NOT rebuild unrelated lanes. Private verified-artifact fetch stages inside a lane build remain allowed.

#### Scenario: Base has no harness binary
- **WHEN** `scripts/validate-image base` runs
- **THEN** shared seat tools are present and `opencode`, `codex`, and `muse` are absent

#### Scenario: Final image composes base plus fragments
- **WHEN** a final image builds
- **THEN** the image contains the shared seat tools from the local base tag plus exactly its declared fragment payloads, with no parent-lane content

### Requirement: Local tag and explicit rebuild
`scripts/build-image` SHALL accept `base` and each final lane name. With no image name it SHALL build the shared base and tag `cistella/opencode:local`. A named final build SHALL rebuild the shared base from cache first, then tag `cistella/<name>:local`. `--no-cache` SHALL apply only to the named image. `scripts/validate-image` SHALL accept the same names and, with no name, check `cistella/opencode:local`. Refresh order SHALL be base first, then independent finals. Rebuild SHALL be an explicit local `podman build`. The change SHALL NOT publish to a registry or configure Quadlet AutoUpdate.

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

#### Scenario: Independence from old intermediaries
- **WHEN** a flat final builds while old intermediary tags are absent
- **THEN** the build succeeds and no sibling image is retagged

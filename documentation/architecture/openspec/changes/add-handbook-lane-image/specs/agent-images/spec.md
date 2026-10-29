## MODIFIED Requirements

### Requirement: Local tag and explicit rebuild
`scripts/build-image` SHALL accept `base`, `opencode`, `codex`, `muse`, or `opencode-pandoc`. With no image name it SHALL build the shared base and tag `cistella/opencode:local`. A named harness build SHALL rebuild the shared base from cache first, then tag `cistella/<name>:local`. `--no-cache` SHALL apply only to the named image. `scripts/validate-image` SHALL accept the same names and, with no name, check `cistella/opencode:local`. Rebuild SHALL be an explicit local `podman build`. The change SHALL NOT publish to a registry or configure Quadlet AutoUpdate.

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

#### Scenario: Handbook build tags its own image
- **WHEN** `scripts/build-image opencode-pandoc` succeeds
- **THEN** `podman image exists cistella/opencode-pandoc:local`

## ADDED Requirements

### Requirement: Effective fingerprint covers pins and recipe content across the closure
Refresh staleness SHALL compare each image's `pc-setup.refresh-pins` label against an effective fingerprint hashing the image's own pins file and Containerfile plus every ancestor's pins file and Containerfile. A recipe-only change SHALL mark the image and all descendants stale. Parents SHALL build before children in dependency order; an opencode-only or base-only change SHALL rebuild all descendants even when a descendant's own pin is HELD; rollback and failure-restore SHALL cover the affected closure's pins and tags.

#### Scenario: Recipe-only change is detected
- **WHEN** a Containerfile changes with all pins unchanged
- **THEN** the image and its descendants are reported stale and rebuilt on apply

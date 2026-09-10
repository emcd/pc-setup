# agent-images Specification

## Purpose
PC Setup production OCI images for Cistella and other agent harnesses: pinned bases, local tags, and build/validate entrypoints.
## Requirements
### Requirement: Digest-pinned Debian trixie-slim base
The production OpenCode image SHALL use `debian:trixie-slim` pinned by multi-arch index digest. The build SHALL fail if the pulled digest does not match the pin. The image SHALL build for `amd64` and `arm64` by selecting arch-specific artifact URLs and checksums from `TARGETARCH`.

#### Scenario: Digest pin honored
- **WHEN** the image is built from the Containerfile
- **THEN** the base image digest matches the recorded pin

#### Scenario: Digest mismatch fails the build
- **WHEN** the recorded base digest does not match the pulled image
- **THEN** the build fails and does not tag `cistella/opencode:local`

### Requirement: Baked Ghostty terminfo
The image SHALL install `ncurses-bin` and `ncurses-term` and SHALL expose Trixie's `ghostty` terminfo as `xterm-ghostty` (symlink under `/usr/share/terminfo/x/`). Runtime SHALL NOT require a host `TERMINFO` environment variable or a host terminfo bind-mount.

#### Scenario: Ghostty terminfo present without host mounts
- **WHEN** `podman run --rm --userns=keep-id -e TERM=xterm-ghostty` runs the image without `TERMINFO` and without a host terminfo bind-mount
- **THEN** `infocmp xterm-ghostty` succeeds and `tput colors` is `256`

### Requirement: User-independent binary paths
The image SHALL place harness and tooling binaries at user-independent paths (`/usr/local/bin`, `/usr/share`, `/opt`) and SHALL NOT pre-seed per-user writable state (`~/.local`, `~/.config`). Writable state SHALL come only from profile allowlist mounts.

#### Scenario: Binary discovery with HOME=/
- **WHEN** `podman run --rm --userns=keep-id -e HOME=/` runs the image
- **THEN** `command -v` finds `opencode`, `agentmux`, `openspec`, `nbspec`, `nb-mcp`, `nb`, `git`, `git-lfs`, `tmux`, and `cc` at user-independent paths and no `EACCES` occurs for binary discovery

### Requirement: Verified version-pinned artifacts
The image SHALL pin tool versions and artifact checksums or lockfiles. The build SHALL NOT execute mutable install scripts (including `https://opencode.ai/install`). The build SHALL fail if a checksum or lock does not match.

#### Scenario: OpenCode comes from a versioned artifact
- **WHEN** the image is built
- **THEN** OpenCode is installed from a versioned GitHub release tarball whose checksum matches the pin

#### Scenario: Checksum mismatch fails the build
- **WHEN** a pinned artifact checksum does not match the downloaded bytes
- **THEN** the build fails and does not tag `cistella/opencode:local`

### Requirement: Dogfood toolchain contents
The image SHALL include Git with LFS, a native compiler and development headers (`build-essential`, `pkg-config`, `libssl-dev`), tmux 3.4 at `/usr/local/bin` built from a checksum-pinned source tarball, Node 24 at `/usr/local`, OpenCode, OpenSpec, Agentmux, NBSpec, `nb-mcp`, and `nb`. The image SHALL NOT install Debian's tmux package. The image SHALL NOT bake a Rust toolchain.

#### Scenario: Compiler present
- **WHEN** `podman run --rm --userns=keep-id` runs `cc --version` in the image
- **THEN** the command succeeds

#### Scenario: OpenCode reports the pinned version
- **WHEN** `podman run --rm --userns=keep-id -e HOME=/tmp` runs `opencode --version`
- **THEN** the output matches the pinned OpenCode version

#### Scenario: Tmux 3.4 client present
- **WHEN** `podman run --rm --userns=keep-id` runs `tmux -V` in the image
- **THEN** the output reports tmux 3.4

### Requirement: Local tag and explicit rebuild
`scripts/build-image` SHALL build the Containerfile and tag `cistella/opencode:local`. `scripts/validate-image` SHALL run the terminfo, binary-discovery, version-pin, and compiler checks against that tag. Rebuild SHALL be an explicit local `podman build`; a `--no-cache` path SHALL exist for pin or Containerfile changes. The change SHALL NOT publish to a registry or configure Quadlet AutoUpdate.

#### Scenario: Build tags the local image
- **WHEN** `scripts/build-image` succeeds
- **THEN** `podman image exists cistella/opencode:local`

#### Scenario: Validate checks the tagged image
- **WHEN** `scripts/validate-image` runs after a successful build
- **THEN** the baked-terminfo, binary-discovery, version-pin, and compiler checks pass


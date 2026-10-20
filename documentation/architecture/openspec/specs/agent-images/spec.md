# agent-images Specification

## Purpose
PC Setup production OCI images for Cistella and other agent harnesses: a pinned shared base, thin harness images, local tags, and build/validate entrypoints.
## Requirements
### Requirement: Digest-pinned Debian trixie-slim base
The shared base image SHALL use `debian:trixie-slim` pinned by multi-arch index digest. The build SHALL fail if the pulled digest does not match the pin. The image SHALL build for `amd64` and `arm64` by selecting arch-specific artifact URLs and checksums from `TARGETARCH`.

#### Scenario: Digest pin honored
- **WHEN** the shared base image is built from its Containerfile
- **THEN** the base image digest matches the recorded pin

#### Scenario: Digest mismatch fails the build
- **WHEN** the recorded base digest does not match the pulled image
- **THEN** the build fails and does not tag `cistella/base:local`

### Requirement: Shared base and thin harness images
PC Setup SHALL publish a shared local image `cistella/base:local` that contains the seat toolchain and SHALL NOT contain a harness binary. Each harness image SHALL start `FROM localhost/cistella/base:local` and SHALL add only its harness binary. A harness pin change SHALL NOT rebuild the shared base.

#### Scenario: Base has no harness binary
- **WHEN** `scripts/validate-image base` runs
- **THEN** shared seat tools are present and `opencode`, `codex`, and `muse` are absent

#### Scenario: Harness image adds only its binary
- **WHEN** `scripts/build-image opencode`, `scripts/build-image codex`, or `scripts/build-image muse` succeeds
- **THEN** the harness image contains that harness binary and the shared seat tools from the local base tag

### Requirement: Baked Ghostty terminfo
The shared base image SHALL expose Trixie's `ghostty` terminfo as `xterm-ghostty` (symlink under `/usr/share/terminfo/x/`). Runtime SHALL NOT require a host `TERMINFO` environment variable or a host terminfo bind-mount. Harness images inherit this layout.

#### Scenario: Ghostty terminfo present without host mounts
- **WHEN** `podman run --rm --userns=keep-id -e TERM=xterm-ghostty` runs a production image without `TERMINFO` and without a host terminfo bind-mount
- **THEN** `infocmp xterm-ghostty` succeeds and `tput colors` is `256`

### Requirement: User-independent layout
Each production image SHALL place harness and tooling binaries at user-independent paths (`/usr/local/bin`, `/usr/bin`, `/usr/share`, `/opt`) and SHALL NOT pre-seed per-user writable state (`~/.local`, `~/.config`). Writable state SHALL come only from profile allowlist mounts. The image SHALL NOT set `EDITOR`. The image SHALL NOT bake a Rust toolchain.

#### Scenario: Binary discovery with HOME=/
- **WHEN** `podman run --rm --userns=keep-id -e HOME=/` runs a production image
- **THEN** image-provided tools are discoverable on `PATH` at user-independent locations and no `EACCES` occurs for binary discovery

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

### Requirement: Host-compatible tmux client
The shared base image SHALL provide tmux 3.4 at `/usr/local/bin` built from a checksum-pinned source tarball. The image SHALL NOT install Debian's tmux package.

#### Scenario: Tmux 3.4 client present
- **WHEN** `podman run --rm --userns=keep-id` runs `tmux -V` in a production image
- **THEN** the output reports tmux 3.4

### Requirement: Distro CLI baseline owned by the Containerfile
Distro-packaged CLI tools beyond the contracts above SHALL be declared in the shared base Containerfile, not in this spec. `scripts/validate-image` SHALL assert discovery of the tools that Containerfile installs.

#### Scenario: Validate follows the Containerfile
- **WHEN** a distro package is added to or removed from the shared base Containerfile runtime install list
- **THEN** `scripts/validate-image` is updated in the same change and this spec is left unchanged

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


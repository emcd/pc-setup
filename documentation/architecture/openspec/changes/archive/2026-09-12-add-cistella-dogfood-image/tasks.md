## 1. Image sources

- [x] 1.1 Add `images/cistella/opencode/pins.env` with index digests, versions, and arch-specific checksums
- [x] 1.2 Add `images/cistella/opencode/Containerfile` on digest-pinned `debian:trixie-slim` with a builder staging prefix and a runtime stage that copies `/out/usr/local` once

## 2. Contents

- [x] 2.1 Install distro packages: `git`, `git-lfs`, `build-essential`, `pkg-config`, `libssl-dev`, `ca-certificates`, `ncurses-bin`, `ncurses-term`
- [x] 2.2 Alias Trixie `ghostty` terminfo as `xterm-ghostty`
- [x] 2.3 Install the pinned Node 24 official tarball under `/usr/local` in the builder
- [x] 2.4 Install OpenCode from the pinned GitHub release tarball into `/usr/local/bin` (not `opencode.ai/install`)
- [x] 2.5 Install OpenSpec from the pinned npm tarball after verifying `dist.integrity`, into `/usr/local`
- [x] 2.6 Install pinned `agentmux` 0.9.0, `nbspec`, and `nb-mcp` via `cargo install --root /usr/local --locked --version` (toolchain at `/opt/rust`)
- [x] 2.7 Install `nb` from the pinned `xwmx/nb` GitHub tag plus sha256 into `/usr/local/bin`
- [x] 2.8 Build tmux 3.4 from the pinned source tarball plus sha256 and install `/usr/local/bin/tmux`; do not install Debian tmux

## 3. Build and validate

- [x] 3.1 Add `scripts/build-image` that passes pins as `--build-arg`, sets `TARGETARCH`, and tags `cistella/opencode:local`
- [x] 3.2 Add `scripts/validate-image` that runs the baked-terminfo, binary-discovery, version-pin, and compiler checks
- [x] 3.3 Document the build, validate, and rebuild (`--no-cache`) flow in the repository README

## 4. Validation

- [x] 4.1 Run `scripts/build-image` successfully on the host
- [x] 4.2 Run `scripts/validate-image` successfully against `cistella/opencode:local`
- [x] 4.3 Run `openspec validate add-cistella-dogfood-image --strict`

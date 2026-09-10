## 1. Image sources

- [ ] 1.1 Add `images/cistella/opencode/pins.env` with digest, version, and checksum pins
- [ ] 1.2 Add `scripts/update-ghostty-terminfo.sh` to vendor Ghostty 1.3.1 `xterm-ghostty` into `data/terminfos/` with the release version recorded
- [ ] 1.3 Run the sync script and commit the vendored terminfo
- [ ] 1.4 Add `images/cistella/opencode/Containerfile` on digest-pinned `debian:trixie-slim` with a builder stage for crates.io installs and a runtime stage that places binaries under `/usr/local`

## 2. Contents

- [ ] 2.1 Install distro packages: `git`, `git-lfs`, `build-essential`, `pkg-config`, `libssl-dev`, `ca-certificates`, `curl`, `ncurses-bin`
- [ ] 2.2 Bake terminfo with `tic -x` into `/usr/share/terminfo`
- [ ] 2.3 Install the pinned Node 24 official tarball under `/usr/local`
- [ ] 2.4 Install OpenCode from the pinned GitHub release tarball into `/usr/local/bin` (not `opencode.ai/install`)
- [ ] 2.5 Install OpenSpec from the pinned npm tarball after verifying `dist.integrity`, into `/usr/local`
- [ ] 2.6 Install pinned `agentmux` 0.9.0, `nbspec`, and `nb-mcp` via `cargo install --locked --version` in the builder stage and copy them to `/usr/local/bin`
- [ ] 2.7 Install `nb` from the pinned `xwmx/nb` GitHub tag plus sha256 into `/usr/local/bin`
- [ ] 2.8 Build tmux 3.4 from the pinned source tarball plus sha256 and install `/usr/local/bin/tmux`; do not install Debian tmux

## 3. Build and validate

- [ ] 3.1 Add `scripts/build-image` that builds and tags `cistella/opencode:local`
- [ ] 3.2 Add `scripts/validate-image` that runs the baked-terminfo, binary-discovery, version-pin, and compiler checks
- [ ] 3.3 Document the build, validate, and rebuild (`--no-cache`) flow in the repository README

## 4. Validation

- [ ] 4.1 Run `scripts/build-image` successfully on the host
- [ ] 4.2 Run `scripts/validate-image` successfully against `cistella/opencode:local`
- [ ] 4.3 Run `openspec validate add-cistella-dogfood-image --strict`

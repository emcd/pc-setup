## Context

PC Setup owns workstation bootstrap, host Podman prerequisites, and production images. Cistella consumes an arbitrary `profile.image` and ships example Dockerfiles as reference only. The current dogfood profile uses `localhost/cistella/opencode:example`, which cannot run a real Cistella development session.

Host: Ubuntu 24.04.4 aarch64, glibc 2.39, rootless Podman 4.9.3, Ghostty 1.3.1. Seat-mounted Rust is rustup `1.95.0` (`GLIBC_2.17`). Tracking: `pc-setup:todos/images/1`. Draft: `pc-setup:ideas/images/1`.

## Goals / Non-Goals

**Goals:**

- One local, rebuildable production image Cistella can consume by tag.
- Verified, version-pinned artifacts at user-independent paths.
- Bake the tools a Cistella dogfood session needs, including a native linker for host-mounted `rustc`.

**Non-Goals:**

- Registry publication (GHCR, Docker Hub).
- Quadlet AutoUpdate or timer-driven refresh.
- Extracting `pc-setup-base` or a per-harness matrix.
- Per-UID/HOME tailoring (Cistella `todos/home/1`).
- Sharing declarative manifests with `ubuntu.bash`.
- Baking the Rust toolchain (the seat still mounts `~/.rustup` and `~/.cargo`).

## Decisions

- **One unified image.** Later base extraction is a `FROM` split, not a matrix to design now.
- **Base: digest-pinned `debian:trixie-slim`.** Ubuntu 24.04 is not a Debian release (host glibc 2.39; Bookworm 2.36; Trixie 2.41). Bookworm was only Cistella's example pin, not an ABI match for Noble. Host rustup `rustc` only needs `GLIBC_2.17`, so either Debian can run it. Trixie is current Debian stable, still slim, and its newer glibc is the safe direction for the mounted compiler. Remaining risk is the link step (`cc`, headers, libstdc++); in-image `build-essential` covers that, and dogfood `cargo build` is the verdict.
- **Tag: `cistella/opencode:local`.** Podman stores `localhost/cistella/opencode:local`. `:local` marks PC Setup production versus Cistella `:example`.
- **Layout follows the tag.** Image-specific files live at `images/cistella/opencode/` (`Containerfile`, `pins.env`). `scripts/build-image` passes pins as `--build-arg` (no `COPY` of pins into the image) and sets `TARGETARCH` from `uname`. Builder keeps the Rust toolchain at `/opt/rust` and installs artifacts to `/usr/local`; the runtime copies `/usr/local` once.
- **Multi-arch:** `FROM` pins the multi-arch index digest. Node and OpenCode tarball URL/sha switch on `TARGETARCH` (`arm64` / `amd64`).
- **Terminfo from Trixie `ncurses-term`.** That package ships `/usr/share/terminfo/g/ghostty`. The runtime aliases it as `xterm-ghostty`. No host `infocmp`, no Ghostty source build, no PPA.
- **Artifacts:** distro packages for `git`, `git-lfs`, `build-essential`, `pkg-config`, `libssl-dev`, `ca-certificates`, `ncurses-bin`, `ncurses-term`. Official Node 24 tarball plus sha256 under `/usr/local`. OpenCode from a GitHub release tarball plus sha256, never `opencode.ai/install`. OpenSpec from the npm `dist.tarball` URL with `dist.integrity` (sha512) recorded in `pins.env`. Agentmux, NBSpec, and `nb-mcp` via `cargo install --locked --version` from crates.io in the builder (`rust:1.95-slim` is Trixie, so its dynamically linked `cargo` matches the builder libc). `nb` from the `xwmx/nb` GitHub tag plus sha256. All of those installs happen in the builder staging prefix, not in the runtime image.
- **Starting pins (host at drafting):** OpenSpec 1.5.0, agentmux 0.9.0, nbspec 0.2.1, nb-mcp 0.14.0, nb 7.24.0, Node 24.14.1. Implementation records exact checksums in `pins.env`.
- **Bake tmux 3.4 from a pinned source tarball.** Agentmux sessions are tmux-based; the in-container client must speak the host server's protocol. Host tmux is 3.4; Trixie's package is not. The builder downloads the tmux 3.4 source tarball, verifies sha256, builds it, and installs `/usr/local/bin/tmux`. Runtime ships Trixie `libevent` and ncurses. Cistella supplies the socket-dir triple and `TMUX` in profile env. Do not install Debian's tmux package.
- **Refresh:** rebuild locally. Pass `--no-cache` when pins or the Containerfile change.

## Risks / Trade-offs

- **Host `rustc` linking on Trixie glibc** → Mitigation: bake `build-essential`, `pkg-config`, and `libssl-dev`; treat dogfood `cargo build` as the verdict.
- **tmux client/server protocol is version-locked (host 3.4)** → Mitigation: build tmux 3.4 from a checksum-pinned source tarball; never the Trixie package.
- **Agentmux protocol skew vs a live source tree** → Mitigation: pin crates.io 0.9.0 to match the installed host relay. Developing unreleased agentmux from inside this image is out of scope.
- **crates.io / GitHub / npm availability at build time** → Mitigation: pin versions and checksums; fail the build on mismatch; do not fall back to `latest`.
- **`nb` CLI becomes redundant after nb-api 0.5.0** → Mitigation: bake it now; remove in a later change when NBSpec and `nb-mcp` no longer need it.
- **Image size from Node + compiler toolchain** → Mitigation: accepted for a unified image; slim by using Trixie slim and not baking Rust.

## Migration Plan

- Build and validate locally. Point the Cistella dogfood profile `image` at `cistella/opencode:local`. Keep Cistella `:example` images untouched. Rollback: retarget the profile to the previous tag and/or remove the local image.

## Follow-ups

- Cistella accepted the Bookworm→Trixie example follow-up (`cistella:todos/15`).
- Cistella adds the tmux socket-dir triple and `TMUX` in the dogfood profile env (no driver change).

## Open Questions

- None.

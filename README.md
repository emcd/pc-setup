# pc-setup

Configuration and maintenance workspace for PC installations.

## Bootstrap

- Full workstation bootstrap (Ubuntu): `bash ~/src/pc-setup/ubuntu.bash`
- Canonical agent harness/CLI installer: `bash ./scripts/install-agent-harnesses`
- Terminal font and glyph fallback installer: `bash ./scripts/deploy-terminal-font-config`
- Agentmux host config backup and deploy: `bash ./scripts/deploy-agentmux-host-config`
- Ghostty terminal emulator installation: `bash ./scripts/install-ghostty`
- Rootless Podman prerequisite validation: `bash ./scripts/validate-rootless-podman`
- Cistella profile mount sources: `bash ./scripts/provision-cistella-mount-sources`
- Cistella profile backup and deploy: `bash ./scripts/deploy-cistella-profiles`
- Cistella images: `bash ./scripts/build-image [base|opencode|codex|muse]` then
  `bash ./scripts/validate-image [base|opencode|codex|muse]`. No argument builds the
  shared base from cache, then the OpenCode image. `--no-cache` applies only
  to the named image. After a shared pin change, rebuild `base`, then each
  harness. Tags: `cistella/base:local`, `cistella/opencode:local`,
  `cistella/codex:local`, `cistella/muse:local`.

## Image Refresh

`scripts/refresh-images` owns the refresh policy (`todos/images/1`):
auto-tracked pins are the OpenCode npm channel (the `latest` dist-tag of
`@opencode/cli`, with each platform tarball resolved from the npm
registry and hashed), Codex GitHub releases, the Muse
`muse-stable` channel (version plus manifest checksums; nothing is
pulled to check), Debian/Rust base digests (remote manifest lookup;
nothing is pulled to check), PyPI distributions (`emcd-agents`,
`hatch`, `pre-commit`, `copier`), and crates.io crates (`agentmux`,
`nbspec`, `nb-mcp-server`, `linecheck`).
PyPI stable tracks the highest eligible stable proven from the release
list (non-dev, non-yanked with files), never bare `info.version`;
`emcd-agents` tracks the highest non-dev, non-yanked release by PEP 440
ordering. Crates use SemVer-correct numeric ranking with prereleases
excluded (PEP 440 misreads tags like `1.2.3-1`). `PRE_COMMIT_VERSION` is on the notify-only
HOLD list (reported every run, never bumped): its bumps must coordinate
`.pre-commit-config.yaml` updates across projects.

- `refresh-images check` — report drift. Exit `0` clean and converged,
  `1` completed check that found work to do or state unknown (upstream
  drift, stale images, skipped tracks, or any combination), `2`
  operational error (network, parse, registry, lock refusal). `1` is
  reserved for completed checks; failures never masquerade as drift. The
  flaky Codex endpoint gets two retries, then its track is skipped with a
  visible notice (pins untouched) instead of failing the run. Check is
  strictly read-only: it never writes pins, tags, builds, or runs,
  even when images are stale — that is what `--apply` is for.
- `refresh-images --apply` — snapshot pins, bump them, preserve `:previous`
  tags, rebuild stale images `--no-cache` (base, then harnesses), validate
  each. Staleness comes from a `pc-setup.refresh-pins` label stamped at
  build time, so retry after a failure (or apply after a rollback)
  converges instead of exiting clean. Any build/validate failure restores
  exact pin bytes plus tags and exits `2`. Concurrent runs are serialized
  with a lock file; a second mutator is refused, never queued.
- `refresh-images --rollback [target]` — re-tag `:previous` over `:local`
  (images only; revert pins with `git`). Preflights every selected
  `:previous` before changing any tag.

Rollout is always manual: after `:local` moves, recreate seats through the
coordinator. `scripts/test-refresh-images` covers the failure paths with
stubbed `curl`/`podman` (exit contract, pin/tag restoration, retry
convergence, lock contention, rollback preflight).

The canonical installer is the shared target for global agent CLI installation
and is intended to avoid duplicated installer logic across repositories.

## Rootless Podman

`ubuntu.bash` installs Podman with the `uidmap`, `slirp4netns`, and
`fuse-overlayfs` helpers required for rootless containers, then validates the
subordinate UID/GID ranges, rootless mode, cgroup v2, overlay storage, and
netavark networking. It creates and validates `~/.config/containers/systemd/`
for future rootless Quadlet units. It also installs `crun` beside `runc` and
pins the rootless default runtime to `runc`. Select crun with
`--runtime crun`.

Use `--userns=keep-id` for agent containers that bind-mount host worktrees.
Ubuntu uses AppArmor; do not apply SELinux-specific `:z` or `:Z` volume labels.
The Cistella project owns container driver profiles and transport validation.

Cistella fail-closes when a profile `host-source` is missing. Until Cistella
grows an opt-in create flag, PC Setup pre-creates those directories.
Container-owned state follows the in-container taxonomy: host
`<type>/cistella/in-container` maps wholesale to guest `<type>`, so seat
state never shadows same-named host state and per-tool directories land
inside the tree without new mounts. Home-level tool state (`~/.cargo`,
`~/.npm`, `~/.rustup`) is shared with the host directly. The dirs are
user-owned, persist
across reboots, and are not backed up. Seat GitHub CLI config:
`~/.config/cistella/in-container/gh` (`0700`, not human `~/.config/gh`).
Do not copy that directory into git. After
`provision-cistella-mount-sources`, hydrate the PAT interactively from
the password database:

```bash
GH_CONFIG_DIR="${HOME}/.config/cistella/in-container/gh" \
  gh auth login --hostname github.com --git-protocol ssh \
  --skip-ssh-key --insecure-storage --with-token
```

Then `chmod 600 "${HOME}/.config/cistella/in-container/gh/hosts.yml"`.

## Terminal Fonts

`scripts/deploy-terminal-font-config` installs `FiraMono Nerd Font Mono` into
`~/.local/share/fonts` and deploys a user-level fontconfig fallback in
`~/.config/fontconfig/conf.d/`. This lets `Ubuntu Sans Mono` remain the primary
monospace font while Neovim statusline glyphs fall back to the Nerd Font before
CJK fonts.

If GNOME Terminal still shows CJK glyphs for Neovim statusline symbols, either
open a new terminal after deployment or configure the profile to use
`FiraMono Nerd Font Mono` directly. To return to distro defaults, remove
`~/.config/fontconfig/conf.d/10-pc-setup-terminal-fonts.conf` and run
`fc-cache --force`.

## Agentmux Config Backup

- Portable production config: `configuration/agentmux/` (`coders.toml`,
  `policies.toml`, `relay.toml`, `ui.toml`, `users.toml`)
- Portable production bundles: `configuration/agentmux/bundles/`
- Agentmux project bundle source: `~/src/agentmux/.auxiliary/configuration/agentmux/bundles/`
- Agentmux QA bundle backup: `configuration/agentmux-qa/bundles/` (from
  `~/src/agentmux/.auxiliary/configuration/agentmux-qa/bundles/`)
- Portable user unit backup location: `configuration/systemd/user/`
- Host deployment command: `bash ./scripts/deploy-agentmux-host-config`
- `example.toml` is intentionally not backed up.
- Live `coder-session-id` fields are stripped from captured bundles.

The deploy script copies production `*.toml` files to `~/.config/agentmux`,
production bundles to `~/.config/agentmux/bundles`, and unit files to
`~/.config/systemd/user`, then attempts `systemctl --user daemon-reload`.
It does not deploy the QA bundle.

## Cistella Config Backup

- Portable seat profiles: `configuration/cistella/profiles/`
  (`opencode.toml`, `cistella-maintainer.toml`)
- Host deployment command: `bash ./scripts/deploy-cistella-profiles`
- `default.toml` is Cistella's baked example and is not backed up.
- Seat `gh` state under `~/.config/cistella/auxiliary/gh` is not backed
  up. Rehydrate with the one-liner in Rootless Podman above.

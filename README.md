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
- Cistella dogfood image: `bash ./scripts/build-image` then `bash ./scripts/validate-image`
  (`bash ./scripts/build-image --no-cache` after pin or Containerfile changes).
  Tag: `cistella/opencode:local`.

The canonical installer is the shared target for global agent CLI installation
and is intended to avoid duplicated installer logic across repositories.

## Rootless Podman

`ubuntu.bash` installs Podman with the `uidmap`, `slirp4netns`, and
`fuse-overlayfs` helpers required for rootless containers, then validates the
subordinate UID/GID ranges, rootless mode, cgroup v2, overlay storage, and
netavark networking. It creates and validates `~/.config/containers/systemd/`
for future rootless Quadlet units.

Use `--userns=keep-id` for agent containers that bind-mount host worktrees.
Ubuntu uses AppArmor; do not apply SELinux-specific `:z` or `:Z` volume labels.
The Cistella project owns container driver profiles and transport validation.

Cistella fail-closes when a profile `host-source` is missing. Until Cistella
grows an opt-in create flag, PC Setup pre-creates those directories. Cache
dirs under `~/.cache/cistella/` are user-owned, persist across reboots, and
are not backed up. First directory: `~/.cache/cistella/cargo`. Seat GitHub
CLI config: `~/.config/cistella/auxiliary/gh` (`0700`, not human
`~/.config/gh`). Do not copy that directory into git. After
`provision-cistella-mount-sources`, hydrate the PAT interactively from
the password database:

```bash
GH_CONFIG_DIR="${HOME}/.config/cistella/auxiliary/gh" \
  gh auth login --hostname github.com --git-protocol ssh \
  --skip-ssh-key --insecure-storage --with-token
```

Then `chmod 600 "${HOME}/.config/cistella/auxiliary/gh/hosts.yml"`.

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

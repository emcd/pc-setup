# pc-setup

Configuration and maintenance workspace for PC installations.

## Bootstrap

- Full workstation bootstrap (Ubuntu): `bash ~/src/pc-setup/ubuntu.bash`
- Canonical agent harness/CLI installer: `bash ./scripts/install-agent-harnesses`

The canonical installer is the shared target for global agent CLI installation
and is intended to avoid duplicated installer logic across repositories.

## Agentmux Config Backup

- Portable bundle backup location: `configuration/agentmux/bundles/`
- Portable user unit backup location: `configuration/systemd/user/`
- Host deployment command: `bash ./scripts/deploy-agentmux-host-config`
- `example.toml` is intentionally not backed up.

The deploy script copies bundles to `~/.config/agentmux/bundles` and unit files
to `~/.config/systemd/user`, then attempts `systemctl --user daemon-reload`.

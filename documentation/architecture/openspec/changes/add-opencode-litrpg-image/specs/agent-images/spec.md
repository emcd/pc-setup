# agent-images delta (add-opencode-litrpg-image)

- **WHEN** `scripts/build-image opencode-litrpg` succeeds
- **THEN** `podman image exists cistella/opencode-litrpg:local`

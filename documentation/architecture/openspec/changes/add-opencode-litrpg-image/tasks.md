## 1. Image recipe

- [x] 1.1 Create `images/cistella/opencode-litrpg/Containerfile` (`FROM localhost/cistella/opencode-pandoc:local`, trixie apt install of the 13 Playwright libraries, alphabetical, `rm -rf /var/lib/apt/lists/*`)
- [x] 1.2 Create `images/cistella/opencode-litrpg/pins.sh` (empty track file with comment: no versioned inputs; fingerprint covers the file plus the Containerfile plus the parent chain)

## 2. Script wiring

- [x] 2.1 Accept `opencode-litrpg` in `scripts/build-image` (build base, then opencode, then opencode-pandoc, then the litrpg layer; parents from cache, `--no-cache` for the named image only; `--skip-parents` for callers that converged the parents already)
- [x] 2.2 Accept `opencode-litrpg` in `scripts/validate-image` (pandoc plus the 13 tool binaries at expected paths; base-inherited checks)
- [x] 2.3 Add the sixth track to `scripts/refresh-images` (track lists, fingerprint inputs over the closure, dependency-order builds, closure rollback, lane-style `--skip-parents`)
- [x] 2.4 Cover the new track in `scripts/test-refresh-images` (skeleton, track lists, fingerprint-want computation) and run the full fixture suite green
- [x] 2.5 Bake `comfy-mcp` + `comfy-cli` (uv tool installs, pinned) into the litrpg image; assert presence in validate-image

## 3. Profile and rollout

- [x] 3.1 Point `configuration/cistella/profiles/opencode-pandoc--litrpg.toml` at `cistella/opencode-litrpg:local` (host first, then sync to repo)
- [x] 3.2 Build the closure in dependency order, validate all six images
- [x] 3.3 Commit unpushed; LitRPG verifies in the actual launch chain

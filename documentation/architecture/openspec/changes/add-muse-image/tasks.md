## 1. Image and pins

- [ ] 1.1 Add `images/cistella/muse/Containerfile` (codex-shaped fetch stage, manifest artifact, install to `/usr/local/bin/muse`)
- [ ] 1.2 Add `images/cistella/muse/pins.sh` seeded from `muse-stable` (`MUSE_VERSION`, per-arch digests, checksum algorithm confirmed)
- [ ] 1.3 Verify in-seat self-update behavior; set the no-update mechanism or record the limitation

## 2. Refresh track

- [ ] 2.1 Add channel/manifest discovery to `scripts/refresh-images` (fail closed on shape drift)
- [ ] 2.2 Add fixture tests covering drift, clean, and failure paths
- [ ] 2.3 Run full suite, `bash -n`, and shellcheck clean

## 3. Wiring and docs

- [ ] 3.1 Teach `scripts/build-image` and `scripts/validate-image` the `muse` name
- [ ] 3.2 Flip the seat profile image to `cistella/muse:local`
- [ ] 3.3 Update task statuses in this change with each completing commit

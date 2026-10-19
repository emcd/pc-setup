## 1. Image and pins

- [x] 1.1 Add `images/cistella/muse/Containerfile` (codex-shaped fetch stage, manifest artifact, install to `/usr/local/bin/muse`)
- [x] 1.2 Add `images/cistella/muse/pins.sh` seeded from `muse-stable` (`MUSE_VERSION`, per-arch digests, checksum algorithm confirmed sha256)
- [x] 1.3 Verify in-seat self-update behavior; set the no-update mechanism or record the limitation (launcher honors `MUSE_NO_AUTO_UPDATE=1`, now set in the seat profile; baked binary runs without the launcher; live-seat phone-home confirmation deferred to first seat run as documented limitation)

## 2. Refresh track

- [x] 2.1 Add channel/manifest discovery to `scripts/refresh-images` (fail closed on shape drift)
- [x] 2.2 Add fixture tests covering drift, clean, and failure paths
- [x] 2.3 Run full suite, `bash -n`, and shellcheck clean (44/44)

## 3. Wiring and docs

- [x] 3.1 Teach `scripts/build-image` and `scripts/validate-image` the `muse` name
- [x] 3.2 Flip the seat profile image to `cistella/muse:local` (trial PATH override removed, `MUSE_NO_AUTO_UPDATE=1` set)
- [x] 3.3 Update task statuses in this change with each completing commit

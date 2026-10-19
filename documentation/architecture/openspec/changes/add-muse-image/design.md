# Design: muse harness image

## Context

Harness images are thin layers over `cistella/base:local`: a fetch stage
downloads a versioned artifact, verifies its checksum against pins, and
installs one binary. Opencode uses GitHub release tarballs; Codex the
same. Muse ships through Meta's channel API instead of GitHub, but the
shape is identical: `muse-stable` channel document gives `version` plus
a manifest URL, and the manifest gives per-platform `url`, `checksum`,
and `size`. Both endpoints are public (no auth), so timer discovery
works unchanged. The channel also reports `urgency`, a free extra
signal. Current version at design time: `1.4.10-R6427.1`; Linux
artifacts run ~376 MB.

## Goals / Non-Goals

Goals: version-tracked muse image built exactly like the other
harnesses; refresh discovery for version plus digests with fixture
tests; seat profile flipped once the image exists.
Non-goals: changing the refresh exit contract, touching other harness
tracks, registry publishing, or solving in-seat self-update beyond
documenting the expected behavior.

## Decisions

- **Track version + digests, not opaque hashes or rebuild-every-run.**
  The channel gives a real version string and checksums, so Muse fits
  the existing pin pattern (`MUSE_VERSION`, per-arch digests) with no
  new policy. Opaque-hash pins would lose the version number for timer
  reports and the downgrade path; rebuild-every-run would break
  reproducibility and make drift detection meaningless.
- **Mirror the Codex Containerfile.** Same fetch stage, same
  `sha256sum --check --strict`, same install to `/usr/local/bin`.
  Only the URL/checksum source differs (channel manifest instead of
  a GitHub release URL).
- **Confirm `checksum_algorithm` at build time.** The manifest names
  the algorithm; the design assumes sha256 (64-hex values observed).
  If it names anything else, the Containerfile adapts rather than
  assuming.

## Risks / Trade-offs

- [376 MB binary bloats build context and seat pulls] → Accept: same
  class as other harness binaries, local tags only, cached layers.
- [Baked binary may attempt self-update inside seats] → Verify during
  build; set the documented no-update mechanism if one exists, else
  record the behavior as a known limitation for a follow-up.
- [Channel API shape drifts] → Discovery parses defensively and fails
  closed (exit 2) on unexpected shape, like other tracks.

## Migration Plan

Land image + pins + refresh track + tests as one commit; flip the seat
profile image in the same commit (it is already deployed at the target
location for trial). Rollback is `git revert`; seats recreate through
the coordinator. No registry state involved.

## Open Questions

- Exact `checksum_algorithm` value (verify against manifest at build).
- Self-update containment inside seats (verify at build).
- Whether to surface channel `urgency` in timer reports (deferred).

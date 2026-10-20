# Design: OpenCode image on OpenCode 2

## Context

OpenCode 2 is published as npm packages, not GitHub releases. The
distribution channel is the meta package `@opencode/cli`, which carries
per-platform optional dependencies and resolves to a native binary through
its own postinstall. The platform packages
(`@opencode/cli-linux-arm64`, `@opencode/cli-linux-x64`, plus `-musl` and
`-baseline` variants) each contain exactly one file of interest,
`package/bin/opencode`, and declare no install script.

Consequences for the image contract:

- `https://github.com/anomalyco/opencode/releases/download/v2.0.32/...`
  returns 404. OpenCode 2 has git tags but no release objects and no
  release assets, so the current fetch source has no V2 equivalent.
- `https://opencode.ai/update/api/latest/cli/opencode/opencode-linux-arm64.tar.gz`
  serves a standalone binary, but only under `latest`; the versioned path
  (`api/2.0.32/...`) is 404. It cannot be pinned.
- The npm registry serves a stable, versioned artifact URL
  (`https://registry.npmjs.org/@opencode/cli-linux-arm64/-/cli-linux-arm64-<version>.tgz`)
  and publishes per-version metadata including `dist.integrity`
  (sha512, base64) and `dist.shasum` (sha1).

The host already runs OpenCode 2.0.32, and the seat mounts the host's
OpenCode config and state, so the harness version moves on both sides of
the same major boundary.

## Goals / Non-Goals

Goals: an OpenCode image on the current upstream major version, built
from a pinned, versioned artifact with the same verification the other
harness images use; a refresh track that keeps tracking upstream
automatically; fixture coverage for the new discovery path.

Non-goals: changing the refresh exit contract, the pin file format, or
the other harness tracks; registry publishing; converting the seat to a
different Opencode configuration layout; deciding anything about the
`cli.json` client-config migration, which this repository does not use.

## Decisions

- **Track the npm channel, resolve per-platform from the registry.**
  Version comes from the `latest` dist-tag of `@opencode/cli`, which is
  the channel definition, and each platform tarball comes from the
  registry document for that version. The channel's other dist-tags
  (`beta`, `dev`) are snapshots and are not tracked.
- **Pin sha256 of the tarball, computed from the downloaded bytes.**
  Every other image pin in this repository is a sha256 hex digest
  (`OPENCODE_SHA256_ARM64`, `CODEX_SHA256_*`, `MUSE_SHA256_*`), and the
  Containerfile verification is `sha256sum --check --strict`. Keeping that
  format means the pin contract and the build-time check do not change.
  The registry's own `dist.integrity` is sha512-base64; adopting it
  would rename the pin fields and change the verification code for no
  trust gain, because the registry's integrity value is not signed
  either. Downloading during discovery has a second benefit: a pin is
  only written after the exact artifact has been fetched successfully.
- **Keep the two-stage Containerfile; change only the URL and the
  member path.** The fetch stage resolves the platform package for
  `TARGETARCH`, verifies the sha256, and extracts
  `package/bin/opencode`. The platform package has no postinstall, so
  nothing executes at build time and the "no mutable install scripts"
  requirement still holds.
- **Let the track follow the channel across majors.** The refresh policy
  already treats upstream drift as a pin bump that the operator reviews
  in the diff before rollout, so a future major is a reviewable pin
  change rather than a silent seat change. The alternative — pinning
  the major line in the script — would add policy the other tracks do
  not have.
- **Leave the harness's own configuration to the seat.** OpenCode 2
  reads the same project-root `opencode.json(c)` the previous version
  read, and the seat mounts the host's OpenCode config, so no
  configuration change is required for the image to work.

## Risks / Trade-offs

- [The V2 binary is 207 MB unpacked, against a smaller V1 release
  artifact] → Accept: same class as the other harness binaries, local
  tags only, cached layers.
- [npm becomes a new supply-chain dependency for this image] → Mitigated
  by the pinned sha256 of the exact tarball, verified at build time
  before the file is installed, with the same fail-closed behavior the
  other tracks use.
- [The image and the host must move together across the major
  boundary] → The host is already on 2.0.32, and the seat shares the
  host's state, so the remaining step is recreating seats after the
  image lands.
- [A track failure now hits a different endpoint than before] → Same
  fail-closed behavior: discovery errors exit 2 with pins untouched.

## Migration Plan

Land the image, pins, refresh track, and tests as one change. The image
is rebuilt locally and validated; seats are recreated through the
coordinator afterwards. Rollback is `git revert` plus a seat recreate;
the refresh script's `--rollback` re-tags the previous image. No
registry state is involved.

## Open Questions

- Whether to surface npm channel snapshots (`beta`, `dev`) as a
  notify-only track (deferred; the channel policy for other tools has
  the same open question).

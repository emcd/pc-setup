## Context

`scripts/setup-steam-arm64-gaming` covers Steam snap install plus GOG
extraction, ending in a Steam-client UI checklist. The client path is
broken (see `pc-setup:artifacts/1`, `/2`): the working route is a
hand-built harness under `~/Games/FEX+Proton/` (pinned Proton 11.0 copy,
per-game prefixes, `fex-proton` launcher via `~/.local/bin` symlink).
Three defects were found and fixed live: symlink-relative path
resolution, whole-tree emulation via `FEXBash`, and running Proton under
the RootFS x86-64 Python. None of this is tracked or reproducible.

Constraints: gaming stays opt-in, host-side, out of `ubuntu.bash` and
seat images; the NVIDIA/DGX package guard stays; the Steam snap pieces
(FEX, RootFS) are referenced read-only.

## Goals / Non-Goals

**Goals:**

- Track the launcher as a reviewable template; deploy it with a new
  `harness` subcommand on the existing script.
- One launcher interface on both architectures (`aarch64` emulated,
  `x86_64` direct).
- Recorded Proton provenance and a scripted save-migration step.
- Checklist corrected so the harness is primary while the client is broken.

**Non-Goals:**

- Fixing the Steam client/container defect (separate track).
- Full AMD64 machine setup (native Steam, drivers); follow-up change.
- Seat images, profiles, timers, relay: untouched.

## Decisions

- **Template beside the setup script** (e.g. `scripts/fex-proton.sh`),
  deployed by copy into `~/Games/FEX+Proton/` plus the
  `~/.local/bin` symlink. Alternative (inline heredoc in the setup
  script) rejected: an untracked template cannot be shell-checked or
  reviewed independently.
- **Arch-adaptive exec inside one launcher** (`uname -m` branch):
  `x86_64` execs Proton directly; `aarch64` goes through `FEXBash`
  with `/usr/bin/python3` (the RootFS x86-64 interpreter, verified
  `platform.machine() == x86_64`). Alternative (host `binfmt_misc`
  registration pointing at `FEXInterpreter`) rejected: persistent host
  mutation requiring root, conflicts with snap confinement.
- **Proton payload is an identified, verified snapshot**: the manifest
  records snap revision, Proton `version` content, and a sha256 content
  manifest over the payload files, checked before deployment. The
  manifest covers the execution-relevant tree structure and link
  targets, rejecting escaping or unverifiable links. Copies
  stage to a temporary directory and publish atomically; an
  interrupted staging tree is never adopted, and re-running restages
  from scratch. A fresh deploy never silently copies newer bytes while
  claiming the reviewed build: deployed bytes MUST match the recorded
  identity. The live hand-built copy is adopted only by verifying its
  digest and recording it as adopted-verified with its actual
  provenance; where verification is impossible the deploy refuses for
  operator resolution and never backfills assumed provenance.
  Redeploys preserve existing payload, prefix, and save bytes. Drift
  comparison (manifest digest versus live bytes) is notify-only; there
  is no auto-upgrade. Alternative payload source (upstream download)
  rejected: Valve ships Proton via Steam depots; third-party tarballs
  are a different build with different behavior.
- **Launcher and symlink collisions refuse**: replacing the managed
  launcher template is intentional, but an unrelated existing file or
  symlink at the launcher or `~/.local/bin` path refuses instead of
  being destroyed.
- **Save migration is explicit, contained, and non-destructive**:
  `migrate-saves` takes an explicit Steam `compatdata/<id>` plus an
  explicit harness game id; there is no auto-detection. Source and
  destination are canonically resolved and MUST remain inside the
  Steam compatdata tree and the harness prefixes tree (traversal or
  symlink escape refuses with no changes). The source stays
  byte-identical. Destination saves survive until a verified copy
  commits: when destination already matches source digests the run is
  a no-op success; otherwise the pre-migration destination is backed
  up, the copy is digest-verified, and any failure or interruption
  retains the previous destination and backup. An existing backup
  refuses replacement of the only backup rather than overwriting it.
  Migration requires the game quiesced on both sides: it refuses
  when a game or Wine process holds the source or the destination
  prefix, and it never kills processes. Demonstrated support is the Gloomhaven
  `FlamingFowlStudios` `LocalLow` layout; other Unity layouts are
  out of scope until demonstrated.
- **Migration is a serialized transaction**: overlapping harness
  mutations serialize on a simple shared lock held through
  destination and backup publication; the managed launcher and
  migration never use the same destination prefix concurrently. The
  plan binds source and destination identities; containment,
  baselines, and backup policy revalidate under the gate before
  commit, and drift or contention refuses without overwriting newly
  written saves or the retained backup. Steam and other launchers
  the tool cannot exclude must remain closed for the whole
  migration interval as an explicit operator precondition
  (documented as a precondition, never misrepresented as proven
  exclusion); active source and destination process checks still
  refuse. Interrupted state stays recoverable: staging never
  publishes partially, and the previous destination plus backup
  survive.
- **Deploy adopts, never clobbers**: prefixes and the Proton copy are
  preserved; only the launcher template is overwritten. The live
  hand-built layout is therefore the migration base, not scrap.
- **Hermetic fixtures before live touch**: fake `FEXBash`, Proton,
  and `uname` plus a disposable `HOME` cover fresh deploy, redeploy
  preservation, partial-copy failure, link collision, architecture
  dispatch (including native success with FEX absent), symlink-derived
  paths, exact argv forwarding (spaces, quotes, empty arguments,
  shell metacharacters), per-architecture missing dependencies,
  unsupported architectures, and the save-migration failure cases
  (including source-held and destination-held refusal). On `aarch64`,
  missing FEX, RootFS, or payload failures exit 2 (normative); on
  `x86_64` FEX absence is the expected native route and missing
  native payload paths fail on that route. Anything else exits
  non-zero without a promised code. Unsupported architectures refuse
  without state damage. Relative exe paths resolve before any
  directory change; per-game prefix and log selection stays confined
  to the harness trees.
- **AMD64 means launcher support, not snap provisioning**: the
  `harness` snap-sourced steps stay `aarch64`-gated; on `x86_64` the
  launcher runs against an already-provisioned compatible
  payload and runtime. The change never claims the ARM64 setup step
  provisions an AMD64 machine.
- **Whole-tree-emulation evidence is version-pinned**: Steam snap rev
  245 (`1.0.0.85`), FEX 2608-era `FEXBash`, RootFS x86-64 Python 3.12.3
  reporting `platform.machine() == x86_64`, Proton 11.0
  (`proton-11.0-2e`, depot build 1791559474), observed Wine children
  starting (no `Exec format error`) and Gloomhaven reaching gameplay
  on that stack. This is evidence for the supported stack, not a
  universal guarantee across revisions.
- **Checklist rewrite keeps host-security scope**: the existing
  AppArmor user-namespace relaxation stays attached to its original
  failure class and is not presented as a harness prerequisite (the
  issue drafts report no AppArmor denials for this defect).

## Risks / Trade-offs

- [Risk] Snap churn moves/removes `/snap/steam/current` pieces → Mitigation:
  the launcher already fails loudly (`exit 2`) on missing paths; the
  hold on rev 245 stays until the client track resolves.
- [Risk] Proton in the snap updates without the harness copy following →
  Mitigation: the manifest records the pinned version; drift is
  operator-visible on the next harness run (documented, not enforced).
- [Risk] `FEXBash` direct-form arg dropping regresses silently →
  Mitigation: the `-c 'exec "$@"' _ ...` pattern is verified and kept
  in a code comment with the failure signature.

## Migration Plan

1. Land the template plus `harness`/`migrate-saves` subcommands.
2. Deploy over the live `~/Games/FEX+Proton/` (adopts prefixes and
   Proton copy; launcher overwritten with the tracked template).
3. Re-run Gloomhaven from the deployed launcher; confirm campaigns load.
4. Rollback is the previous template bytes from git; prefixes are
   never touched by rollback.

## Open Questions

- Exact template filename (implementation detail; e.g.
  `scripts/fex-proton.sh`). Source selection is decided: explicit
  `compatdata` id, no auto-detection.

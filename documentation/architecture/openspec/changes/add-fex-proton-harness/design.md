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
  targets, rejecting escaping or unverifiable links. Copies stage to
  a temporary directory and publish atomically; the staged tree must
  digest-match BOTH the snap source (faithful copy) AND a tracked
  expected snapshot (`scripts/proton-expected-manifest`, updated
  deliberately with re-validation, never automatically). A fresh
  deploy of anything else refuses as an unreviewed build. Fresh
  deploys require an executable proton entry point. On redeploy,
  upstream source drift stays notify-only with no auto-upgrade;
  installed bytes that no longer match the recorded manifest are
  unverified and refuse the run (no launcher refresh, no ready
  message) rather than being waved through. The live hand-built copy
  is adopted only by verifying its digest and link containment, and
  recording it as adopted-verified with the snap revision observed
  at adoption (never a backfilled historical claim); where
  verification is impossible the deploy refuses for operator
  resolution. Alternative payload source (upstream download)
  rejected: Valve ships Proton via Steam depots; third-party tarballs
  are a different build with different behavior.
- **Launcher deployment is managed and tracked**: a launcher-manifest
  records the digest of the deployed template. The collision decision
  (install / no-op / managed replace / refuse) is made before any
  payload staging or directory creation, and re-verified at deploy
  time. Replacement is allowed only when the destination is absent,
  byte-identical to the new template (no-op), or matches the recorded
  digest (managed update). Unrelated or non-regular files refuse;
  symlinks are never followed or replaced. The convenience symlink
  refuses when it points elsewhere or a non-symlink occupies the path.
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
  prefix, and it never kills processes. Process matching is literal
  (regex-escaped): metacharacters in harness paths must not widen or
  blind the match. Demonstrated support is the Gloomhaven
  `FlamingFowlStudios` `LocalLow` layout; other Unity layouts are
  out of scope until demonstrated.
- **Migration is a serialized transaction**: overlapping harness
  mutations serialize on a simple shared lock held through
  destination and backup publication; the managed launcher and
  migration never use the same destination prefix concurrently. The
  plan binds source and destination identities; containment,
  baselines, and backup policy revalidate under the gate before
  commit, and drift or contention refuses without overwriting newly
  written saves or the retained backup. Revalidation re-resolves
  every path (source tree, destination parent, backup) and rejects
  ancestor or final-link substitution even when bytes are identical,
  plus source-digest drift, destination appearance/type change, and
  backup drift. Steam and other launchers the tool cannot exclude
  must remain closed for the whole migration interval as an explicit
  operator precondition (documented as a precondition, never
  misrepresented as proven exclusion); active source and destination
  process checks still refuse. Commit is atomic: the destination
  rotates aside to a replace directory, the staged tree publishes,
  and any publish or verification failure restores exact bytes from
  the replace dir; the `.fresh` backup is an archive and is never
  consumed by recovery. A leftover replace dir with an absent
  destination is restored on the next run; with a present
  destination it refuses. Interrupted staging never publishes.
  Leftover-state globbing is space-safe (nullglob array, never word
  split). Staging must share a filesystem with the destination
  (verified by filesystem id); cross-filesystem layouts refuse
  instead of letting plain mv silently copy.
- **Deploy adopts, never clobbers**: prefixes and the Proton copy are
  preserved; only the launcher template is overwritten. The live
  hand-built layout is therefore the migration base, not scrap.
- **Hermetic fixtures before live touch**: fake `FEXBash` (with
  sysroot interpreter mapping), Proton, `uname`, `dpkg-query`,
  `snap`, `pgrep`, `cp`, and `mv` plus a disposable `HOME` cover fresh deploy, redeploy preservation,
  partial-copy and publish failure with restore, link collision,
  architecture dispatch (including native success with FEX absent),
  symlink-derived paths, exact argv forwarding (spaces, quotes,
  empty arguments, shell metacharacters), per-architecture missing
  dependencies (present-but-unrunnable emulator, missing RootFS
  interpreter, missing payload), unsupported architectures, and the
  save-migration failure cases (including source-held and
  destination-held refusal proved separately, competing migrators,
  both launch-vs-migration orders with real child lifetime,
  check-to-commit drift, replace-symlink recovery refusal, and a
  space-containing-HOME deploy (a stale-replace-under-held-prefix
  interleaving test was trimmed as unfixably flaky; ordering is
  covered by inspection plus the held-prefix tests). Fixture lock holders are reaped via
  /proc fd inspection (no fuser dependency) with readiness barriers
  (wait-until-held / wait-until-free) instead of fixed sleeps, so no
  test passes for a stale-lock reason. On `aarch64`, missing FEX,
  RootFS, or payload failures exit 2 (normative) before any prefix,
  log, or lock state is created; on `x86_64` FEX absence is the
  expected native route and missing native payload paths fail on
  that route. Anything else exits non-zero without a promised code.
  Unsupported architectures refuse without state damage. Relative
  exe paths resolve before any directory change; per-game prefix
  and log selection stays confined to the harness trees, with
  ancestor symlinks refused before creation and admitted layouts
  re-verified after.
- **Launcher preflight precedes all mutation**: game-id validation,
  architecture support, runtime presence plus a runnable probe that
  executes the RootFS interpreter through the configured FEXBash
  invocation (not a bare no-op probe, and only after the FEX
  environment variables the probe must exercise are exported), and
  ancestor symlink checks all run before the lock is taken; `mkdir`
  follows the lock, and admitted layouts re-verify after creation.
  A `realpath -m` containment check also runs before `mkdir`, so no
  creation precedes verification. The runnable probe (not mere
  existence) and the interpreter file check are what the
  missing-runtime exit-2 contract stands on.
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

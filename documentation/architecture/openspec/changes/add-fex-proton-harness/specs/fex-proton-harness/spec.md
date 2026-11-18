## ADDED Requirements

### Requirement: Harness deployment is reproducible and idempotent

The setup script SHALL deploy the tracked launcher template, Proton
payload, prefix layout, and convenience symlink, preserving existing
prefixes and saves across re-runs.

#### Scenario: Fresh harness deployment

- **WHEN** the operator runs the `harness` subcommand with no prior
  `~/Games/FEX+Proton/` layout
- **THEN** the layout (`proton/`, `prefixes/`, `logs/`), launcher, and
  `~/.local/bin/fex-proton` symlink exist and the Proton manifest
  records source plus version.

#### Scenario: Redeploy preserves game state

- **WHEN** the operator re-runs the `harness` subcommand over an
  existing layout with prefixes and saves
- **THEN** payload, prefixes, and saves are byte-identical afterwards
  and only the launcher template is refreshed.

### Requirement: Proton payload is verified before deployment

The setup script SHALL publish only a staged, digest-verified Proton
snapshot whose bytes match the recorded manifest identity, and SHALL
refuse adoption, drift, or collision cases it cannot verify.

#### Scenario: Interrupted staging is never adopted

- **WHEN** a staged copy is incomplete or its digest mismatches
- **THEN** deploy exits non-zero and no partial tree is published;
  re-running restages from scratch.

#### Scenario: Newer-bytes drift refuses or reports

- **WHEN** the snap payload identity differs from the recorded
  manifest on a fresh deploy
- **THEN** deploy refuses rather than silently copying newer bytes
  while claiming the reviewed build; on redeploy the difference is
  reported notify-only with no auto-upgrade.

#### Scenario: Live copy is adopted honestly

- **WHEN** the deploy finds the existing hand-built Proton copy
- **THEN** its digest is verified and recorded as adopted-verified
  with the snap revision observed at adoption (never a backfilled
  historical claim), or adoption refuses for operator
  resolution; assumed provenance is never backfilled.

#### Scenario: Corrupting copy is rejected

- **WHEN** a copy tool exits success but the staged tree digest
  differs from the source digest
- **THEN** deploy refuses and publishes nothing; hashing only the
  staged tree is not accepted as verification.

#### Scenario: Escaping payload link is rejected

- **WHEN** the staged payload contains a symlink resolving outside
  the staged tree
- **THEN** deploy refuses and publishes nothing, even when digests
  are self-consistent.

#### Scenario: Upstream drift and unverified bytes are distinguished

- **WHEN** the recorded manifest exists and the snap source version
  differs from it
- **THEN** deploy reports identified upstream drift without
  auto-upgrading; when instead the installed bytes differ from the
  manifest digest, deploy refuses without refreshing the launcher
  or reporting ready. The two states are never conflated, and
  notify-only drift never certifies unknown bytes.

#### Scenario: Managed launcher replacement is tracked

- **WHEN** the launcher destination holds the previously deployed
  bytes (digest matches the launcher manifest) or content
  identical to the new template
- **THEN** deploy replaces or no-ops respectively; when it holds an
  unrelated file, or any symlink, deploy refuses without following
  the link or destroying anything.

#### Scenario: Unrelated collision refuses

- **WHEN** an unmanaged file or symlink occupies the launcher or
  convenience-symlink path
- **THEN** deploy refuses without destroying it.

### Requirement: One launcher works on both architectures

The launcher SHALL run a Windows x86-64 game through Proton on
`aarch64` (emulated) and `x86_64` (direct) with the same arguments.

#### Scenario: ARM64 launch stays emulated

- **WHEN** the launcher runs on `aarch64` with a game id plus exe path
- **THEN** Proton executes under the RootFS x86-64 interpreter and
  the prefix is created without `Exec format error`.

#### Scenario: AMD64 launch runs direct

- **WHEN** the launcher runs on `x86_64` with a game id plus exe path
- **THEN** Proton executes directly with no FEX involvement and the
  prefix is created.

#### Scenario: Launcher follows its symlink

- **WHEN** the launcher is invoked via the `~/.local/bin` symlink
- **THEN** it resolves Proton, prefixes, and logs under the real
  install directory.

### Requirement: Launcher and deploy fail loudly with stable codes

The launcher and setup script SHALL refuse unsupported environments
and missing dependencies without state damage, with exit 2 reserved
for missing runtime or path dependencies.

#### Scenario: Missing runtime exits 2 on ARM64

- **WHEN** on `aarch64` the FEX entry point is missing, unexecutable,
  or unrunnable, the RootFS or its x86-64 interpreter is absent, or
  the Proton payload is missing or not executable
- **THEN** the launcher exits 2 before creating any prefix, log, or
  lock state.

#### Scenario: Symlinked ancestor refuses without state

- **WHEN** a prefixes or logs ancestor is a symlink pointing outside
  the install directory
- **THEN** the launcher refuses without creating state or writing
  through the link.

#### Scenario: Unrunnable interpreter refuses without state

- **WHEN** the configured RootFS interpreter exists but cannot run
  through the emulator
- **THEN** the launcher refuses with exit 2 before any prefix, log,
  or lock state is created.

#### Scenario: Native success with FEX absent on AMD64

- **WHEN** on `x86_64` with a provisioned native Proton payload and
  no FEX present
- **THEN** the launcher runs directly with no FEX involvement.

#### Scenario: Unsupported architecture refuses

- **WHEN** run on an architecture other than `aarch64` or `x86_64`
- **THEN** launcher and setup refuse without state damage.

#### Scenario: Tricky arguments survive intact

- **WHEN** the exe path or game arguments contain spaces, quotes,
  empty strings, or shell metacharacters
- **THEN** Proton receives them exactly.

#### Scenario: Relative exe resolves before directory change

- **WHEN** the exe path is relative
- **THEN** it is resolved before the launcher changes directory.

#### Scenario: Prefix and log selection is confined

- **WHEN** a game id is given
- **THEN** prefix and log paths stay within the harness trees.

### Requirement: Save migration is explicit and non-destructive

`migrate-saves` SHALL take an explicit Steam `compatdata` id plus an
explicit harness game id, keep the source byte-identical, contain
both trees, and never lose destination saves or the only backup.
Demonstrated support is the Gloomhaven save layout; other Unity
layouts are out of scope.

#### Scenario: Absent or invalid source refuses

- **WHEN** the named `compatdata` id has no save tree, or the id is
  invalid
- **THEN** migration exits non-zero with no filesystem changes.

#### Scenario: Unsafe paths refuse

- **WHEN** a game id or resolved path escapes its tree through
  traversal or a symlink
- **THEN** migration exits non-zero with no filesystem changes.

#### Scenario: Existing backup is not replaced

- **WHEN** a backup already exists and the destination differs from
  the source
- **THEN** migration refuses rather than replacing the only backup.

#### Scenario: Repeated identical run is a no-op

- **WHEN** the destination already matches the source digests
- **THEN** migration succeeds without copying.

#### Scenario: Failed copy retains previous state

- **WHEN** the copy or its digest verification fails or is
  interrupted
- **THEN** the previous destination saves and backup remain intact.

#### Scenario: Process matching is literal

- **WHEN** prefix paths contain regex metacharacters
- **THEN** the held-prefix check matches them literally: a holding
  process is found, and a non-matching name is not mistaken for one.

#### Scenario: Running game refuses

- **WHEN** a game or Wine process holds the source or the
  destination save tree
- **THEN** migration refuses without touching any process.

#### Scenario: Competing migration serializes

- **WHEN** a second migration targets a prefix with a migration
  already in progress
- **THEN** it waits on or refuses via the shared lock without
  interleaving mutations.

#### Scenario: Managed launch during migration refuses

- **WHEN** the managed launcher targets a destination prefix with
  a migration in progress
- **THEN** it refuses rather than running concurrently.

#### Scenario: Ancestor or final-link substitution refuses

- **WHEN** a source or destination ancestor or the final save-tree
  entry is substituted (including by a symlink to an identical
  tree outside the admitted roots) between validation and commit
- **THEN** migration refuses without publishing and without writing
  outside the admitted trees, even when all bytes are identical.

#### Scenario: Source drift refuses a stale snapshot

- **WHEN** the source save tree changes between initial validation
  and commit
- **THEN** migration refuses rather than publishing a stale
  snapshot; digest equality alone never substitutes for identity.

#### Scenario: Publish failure restores exact state

- **WHEN** the atomic publish or its verification fails
- **THEN** the previous destination is restored byte-identical from
  the rotate-aside copy and the `.fresh` backup is untouched.

#### Scenario: Replace symlink is never adopted

- **WHEN** a leftover replace path is a symlink rather than a
  directory
- **THEN** recovery refuses without adopting it, even when the
  destination is absent.

#### Scenario: Held prefix blocks recovery

- **WHEN** a game or Wine process holds the source or destination
  while a leftover replace dir waits
- **THEN** migration refuses before any recovery write, leaving
  the replace dir stranded for a later clean run.

#### Scenario: Process matching is literal

- **WHEN** prefix paths contain regex metacharacters
- **THEN** the game-held check matches those literal paths: a
  holding process is found, and a non-matching process is not
  mistaken for one.

#### Scenario: Destination or backup drift refuses

- **WHEN** the destination or backup state changes between initial
  validation and commit (appearance, type change, or digest drift)
- **THEN** migration refuses without publishing over newly written
  saves or replacing the retained backup.

#### Scenario: Source-side closure is an explicit precondition

- **WHEN** Steam or another unmanaged launcher could write the
  source tree
- **THEN** migration proceeds only under the documented operator
  precondition that they remain closed for the whole interval.

#### Scenario: Gloomhaven campaign transfer

- **WHEN** the operator runs save migration for the Gloomhaven
  prefix with the game closed
- **THEN** both campaigns load in the harness game and the
  pre-migration saves remain available under backup.

### Requirement: Guidance presents the working path first

The setup script's closing checklist SHALL present the harness as the
primary play path while the Steam client is broken.

#### Scenario: Stale checklist corrected

- **WHEN** the operator runs `setup` after this change
- **THEN** the printed steps lead with the harness launch and mark
  the Steam-client UI route as currently broken with pointers to the
  tracked issue drafts.

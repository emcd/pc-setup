## 1. Launcher template

- [ ] 1.1 Add tracked `fex-proton` launcher template beside `scripts/setup-steam-arm64-gaming`, carrying the live fixes (symlink-safe directory resolution, `FEXBash` whole-tree emulation, RootFS x86-64 Python, `-c 'exec "$@"'` arg forwarding, stable working directory so game logs land under the harness instead of the caller's cwd).
- [ ] 1.2 Add the `uname -m` branch so `x86_64` execs Proton directly while `aarch64` keeps the emulated route.
- [ ] 1.3 Pass `check-shell-syntax` (and any repo shell lint) over the template.

## 2. Setup script harness support

- [ ] 2.1 Add the `harness` subcommand: create `~/Games/FEX+Proton/` layout, stage plus digest-verify the Proton payload before atomic publish (interrupted staging is never adopted), write the snap-revision plus sha256 identity manifest, adopt the live copy only as verified-adopted, deploy the launcher template, manage the symlink with refusal on unrelated collisions, preserve existing payload plus prefixes plus saves on redeploy.
- [ ] 2.2 Add the save-migration step for an explicit Steam `compatdata/<id>` into a harness prefix: canonical containment, source byte-identical, digest-verified copy, `.fresh` backup never replaced, identical re-run is a no-op, failure retains previous state, refuse when the game holds the source or the destination prefix, serialized on a shared lock with identity binding and commit-time revalidation, source launchers closed for the whole interval as an operator precondition.
- [ ] 2.3 Correct the closing checklist to lead with the harness path and mark the Steam-client UI route broken with pointers to `pc-setup:artifacts/1` and `/2`; the existing AppArmor user-namespace relaxation stays scoped to its original failure class and is not presented as a harness prerequisite.
- [ ] 2.4 Keep the NVIDIA/DGX package guard, `aarch64` gate for snap-sourced steps, and the no-seat-image boundary intact.

## 3. Verification

- [ ] 3.1 Add hermetic fixtures (fake `FEXBash`, Proton, and `uname` plus disposable `HOME`) covering fresh deploy, redeploy byte preservation, partial-copy failure, link collision, arch dispatch including native success with FEX absent, symlink-derived paths, argv edge cases (spaces, quotes, empty, metacharacters), per-architecture missing dependencies, unsupported arch, and the save-migration failure cases including source-held and destination-held refusal, competing migrators, managed-launch-versus-migration exclusion, and check-to-commit drift; no game launch required.
- [ ] 3.2 Deploy over the live `~/Games/FEX+Proton/` layout and confirm prefixes plus saves are untouched (requires explicit operator go-ahead; review approval alone does not authorize live deployment).
- [ ] 3.3 Launch Gloomhaven from the deployed launcher and confirm both campaigns load (requires explicit operator go-ahead; review approval alone does not authorize game or save mutation).
- [ ] 3.4 Run `openspec validate --all --strict` for the change.

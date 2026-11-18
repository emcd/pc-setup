## 1. Launcher template

- [x] 1.1 Add tracked `fex-proton` launcher template beside `scripts/setup-steam-arm64-gaming`, carrying the live fixes (symlink-safe directory resolution, `FEXBash` whole-tree emulation, RootFS x86-64 Python, `-c 'exec "$@"'` arg forwarding, stable working directory so game logs land under the harness instead of the caller's cwd).
- [x] 1.2 Add the `uname -m` branch so `x86_64` execs Proton directly while `aarch64` keeps the emulated route.
- [x] 1.3 Pass `check-shell-syntax` (and any repo shell lint) over the template.

## 2. Setup script harness support (reopened per Tier-1 B1–B4)

- [x] 2.1 Harness subcommand with staged-vs-source verification, escaping-link rejection, executable entry check, drift distinction, honest adoption, launcher-manifest collision tracking. REOPENED items closed.
- [x] 2.2 Atomic publish with replace-dir recovery, under-gate identity/containment revalidation, source drift refusal, literal process matching. REOPENED items closed.
- [x] 2.3 Checklist now leads with the harness path; Steam-client route marked broken with issue pointers; AppArmor stays scoped to its original failure class.
- [x] 2.4 Keep the NVIDIA/DGX package guard, `aarch64` gate for snap-sourced steps, and the no-seat-image boundary intact.

## 3. Verification

- [x] 3.1 Hermetic fixtures (fake dpkg-query/mv/pgrep, disposable HOME, full layouts, both start orders, real child lifetime, literal matching, B1–B4 boundaries); 34/34 passing.
- [x] 3.2 Deploy over the live `~/Games/FEX+Proton/` layout and confirm prefixes plus saves are untouched (requires explicit operator go-ahead; review approval alone does not authorize live deployment).
- [x] 3.3 Launch Gloomhaven from the deployed launcher and confirm both campaigns load (requires explicit operator go-ahead; review approval alone does not authorize game or save mutation).
- [x] 3.4 Run `openspec validate --all --strict` for the change.

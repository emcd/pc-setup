## 1. Inventory

- [ ] 1.1 Capture the live `uv tool list`, classify each tool by install site (`ubuntu.bash` versus `scripts/install-agent-harnesses`), and record specs including `--with` constraints with one-line reasons.
- [ ] 1.2 Verify on this host that `uv tool upgrade` retains recorded `--with` constraints (receipt check), and record the verified uv version.

## 2. Bootstrap wiring

- [ ] 2.1 Add the inventoried installs to their classified sites (idempotent; never remove or alter existing installs).
- [ ] 2.2 Add a drift check comparing `uv tool list` against the inventory (report-only, non-zero exit on difference).
- [ ] 2.3 Pass shell lint over touched scripts.

## 3. Verification

- [ ] 3.1 Run the drift check on this host; reconcile intentional extras explicitly.
- [ ] 3.2 Run `openspec validate --all --strict` for the change.

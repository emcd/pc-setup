## Context

`ubuntu.bash` records one `uv tool install` (Maestral, now pinned). The
host carries ~14 more tool installs with no tracked record: harness and
site CLIs installed ad hoc over the machine's lifetime. A fresh
bootstrap silently drops them, and there is no inventory to diff
against. Tool configuration and credentials stay out of scope; only
the install specs are recorded.

## Goals / Non-Goals

**Goals:**

- A complete, reviewable inventory of intended `uv tool` installs
  with exact specs including `--with` constraints.
- Fresh-bootstrap convergence: running the bootstrap path installs
  every inventoried tool (idempotent; existing installs untouched).
- A receipt check (`uv tool list` versus inventory) that reports
  drift without mutating.

**Non-Goals:**

- Credential, auth, or state migration (keyrings, logins, tool data).
- npm/global packages, seat images, timers.

## Decisions

- **One inventory, two install sites**: host-wide CLI tooling that
  every seat session inherits stays in `ubuntu.bash`; anything tied
  to the agent-harness workflow joins `scripts/install-agent-harnesses`
  next to the npm installs. Alternative (single new installer script
  for all uv tools) rejected: it splits one concern across yet
  another entry point the operator must remember; the two existing
  sites already express the host/harness boundary.
- **Record `--with` constraints as install spec, not comments**: the
  constraint is what makes the install reproducible (Maestral proves
  it), and `uv` persists it in the tool receipt across upgrades.
  Bare `tool install <name>` is accepted only when the tool has no
  known constraint.
- **Inventory doubles as the drift check**: the implementation
  compares `uv tool list` output against the inventory and reports
  extras/missing without installing or removing. No auto-install on
  check; bootstrap installs, check only reports.

## Risks / Trade-offs

- [Risk] A pinned `--with` rots as upstreams move → Mitigation: pins
  carry a one-line reason; the drift check surfaces available
  updates without applying them.
- [Risk] `uv tool upgrade` semantics for `--with` change upstream →
  Mitigation: the receipt file is verified as part of implementation
  on this host's uv version, and the fact is recorded in the task.
- [Risk] Tools with GUI extras or system deps (Maestral `[gui]`)
  need more than `uv tool install` → Mitigation: such needs are
  recorded alongside the entry; system packages stay in the apt list.

## Migration Plan

1. Inventory the live toolset; classify each entry by install site.
2. Land the inventory plus bootstrap wiring.
3. Run the drift check on this host; reconcile intentional extras.
4. No rollback beyond reverting the bootstrap edit; installed tools
   are never removed by this change.

## Open Questions

- None structural. Per-tool classification happens at implementation
  time against the live `uv tool list`.

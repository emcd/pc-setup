## ADDED Requirements

### Requirement: UV tool installs are inventoried and reproducible

The bootstrap path SHALL declare every intended `uv tool` install
with its exact spec including `--with` constraints, install any
missing entry idempotently, and never remove or alter existing
installs to converge.

#### Scenario: Fresh bootstrap installs the inventory

- **WHEN** the bootstrap path runs on a machine without the tools
- **THEN** every inventoried tool installs with its recorded spec
  and constraints.

#### Scenario: Re-run preserves existing installs

- **WHEN** the bootstrap path re-runs over existing installs
- **THEN** installed tools are byte-identical afterwards (upgrades
  only on explicit operator action, never as a side effect).

### Requirement: Inventory drift is reported, not auto-fixed

A check SHALL compare `uv tool list` against the inventory and
report missing or extra tools without installing or removing
anything.

#### Scenario: Drift report

- **WHEN** the operator runs the drift check with an extra tool
  installed or an inventoried tool missing
- **THEN** the check names the difference and exits non-zero with
  no mutations.

### Requirement: Pins carry their reason and survive upgrades

Each `--with` constraint SHALL record why it exists, and the tool
receipt SHALL retain it across `uv tool upgrade` runs on the
pinned host uv version.

#### Scenario: Maestral pins hold

- **WHEN** the operator runs `uv tool upgrade maestral`
- **THEN** the resolved set still honors `dropbox<12` and
  `setuptools<81`, or the upgrade refuses rather than silently
  dropping the constraints.

# OpenSpec Instructions

This project uses OpenSpec 1.x (OPSX), the action-based workflow. OPSX skills
deliver workflow instructions through the agentsmgr distribution pipeline.

## Workflow

- `opsx-propose` -- create a complete change proposal in one step.
- `opsx-explore` -- think through ideas before committing to a change.
- `opsx-apply` -- implement tasks from an approved change.
- `opsx-sync` -- sync delta specs into main specs.
- `opsx-archive` -- archive a completed change.

## Clone Setup

A fresh clone is missing everything only populate creates: the
`openspec/` symlink (to `documentation/architecture/openspec`),
agent harness symlinks, and MCP discovery symlinks such as
`.mcp.json`. The canonical definitions those links point at —
`.auxiliary/configuration/mcp-servers.json` and coder settings —
are rendered by Copier and tracked. The `.git/info/exclude` entries
covering the managed links are established alongside population, not
inherited. After any `copier copy` or `copier update` involving the
`agents-common` Copier template, you must run:

    agentsmgr populate project github:emcd/agents-common@master#distribution

Without the `openspec` symlink, `openspec validate --all --strict`
reports "No items found to validate" and exits 0 while validating
nothing; do not report that as a pass.

## CLI State Queries

- `openspec list` and `openspec list --specs` -- active changes and specs.
- `openspec status --change <id>` -- artifact state for a change.
- `openspec instructions <artifact> --change <id>` -- authoring instructions.
- `openspec validate --all --strict` -- validate changes and specs.

## Conventions

- Project configuration: `openspec/config.yaml` (default schema:
  `spec-driven`). Custom workflow schemas may be added under
  `openspec/schemas/` as the project evolves.
- Change IDs: kebab-case, verb-led (`add-`, `update-`, `remove-`,
  `refactor-`).
- Every requirement uses SHALL/MUST and carries at least one
  `#### Scenario:` (exactly four hashtags).
- When a commit completes an OpenSpec task or requirement, update the
  relevant task status in the same commit.
- When a commit changes a requirement's wording, sweep `design.md` and
  `proposal.md` for the same claim, not only the delta spec and
  `tasks.md`. `openspec validate --strict` checks structure, not
  agreement among a change's own documents.
- Consulting this procedure does not authorize creating a proposal.

Review and merge proposal commits through @.auxiliary/agents/procedures/reviews.md. Do not amend a proposal commit while review is in progress, and do not require a pinhole `git show` review. No notebook draft step.

# Applying Template Updates

This guide covers updating a project built from the agents-common
Copier template, and the `agentsmgr populate` step that goes with it.
It is template-owned: corrections land here, not in per-project files.

## Standard update

Run the update non-interactively with the data file, then populate
from this repository's `distribution/` tree:

Copier requires the data file as a local file, not a URL —
download it first (replace `<ref>` with the agents template tag
under adoption), then update, then populate:

```sh
DATA_FILE="$(mktemp)" || exit 1
trap 'rm -f "$DATA_FILE"' EXIT INT TERM
python3 -c "import sys, urllib.request; urllib.request.urlretrieve('https://raw.githubusercontent.com/emcd/agents-common/<ref>/.auxiliary/data/copier/single-source-instructions.yaml', sys.argv[1])" "$DATA_FILE"
copier update \
    --data-file "$DATA_FILE" \
    --answers-file .auxiliary/configuration/copier-answers--agents.yaml \
    --skip-answered
agentsmgr populate project <source>/distribution <target>
```

Track the latest release by default: a bare `copier update` selects
the latest template tag on its own. Pin `--vcs-ref` to a tag only when
a specific version was explicitly requested (for example, to reproduce
an exact run); a pin that merely dodges an environment problem is a
workaround, not a fix — fix the environment instead. Whatever ref the
update uses, the data-file URL must name the same tag in place of
`<ref>`: the file carries renamed answers so the update does not
silently keep a retired layout, and it holds no guidance beyond that.
(If this project also uses the Rust template, it keeps a separate
answers file alongside this one; each template's copy and populate
leaves the other's answers file untouched.)

Do not pass `--quiet`: the post-update banner is suppressed in quiet
mode, and you will miss conflict and follow-up notices.

Copier update is a three-way merge, not an overwrite: it re-renders
the old template at your recorded `_commit` and the new one, then
merges the template's evolution against yours. Conflict markers
surface only where both sides changed the same region. If project
content vanishes without markers in the file, that alone does not
identify the mechanism — possibilities include a stale merge base (a
recorded `_commit` older than the file's true lineage), overwrite
semantics, or a rejection conflict mode (`--conflict rej` writes
markers to `.rej` files and leaves the upstream value in place).
Inspect `git diff`, any `.rej` files, the recorded ref, and the
selected conflict mode before diagnosing. Either way, back up
project augmentations such as MCP server additions before updating
so nothing depends on reconstructing the mechanism afterward.

## Ordering rules

- **Update first, then populate.** Populate aborts when the
  template-rendered `.auxiliary/agents/agents.md` does not exist yet.
- **Review before populating.** Resolve update conflicts first; do
  not populate over a conflicted tree.
- **Commit together.** Land the update and the populate in the same
  changeset. Committing the update first leaves downstream clones
  holding half-migrated trees.

## Retired content

When the template retires something, delete leftover tracked copies
outright. Do not add exclude entries for retired paths: removed means
absent, not excluded. Populate copies but never deletes, so stale
trees (old instruction homes, retired `coders/*/agents` and
`coders/*/commands` directories, legacy `*.rst` standards) must be
removed by hand.

A moved or reformatted key is not a line-level change: Copier's merge
can keep both the stale local copy and the template's new one (seen
with a duplicated JSON key that the `check-json` hook then rejects).
After updating, treat hook failures about duplicate keys as this
shape until proven otherwise — delete the stale copy by hand so the
file matches a fresh template render.

## Custom skills

Project-owned skills live in `.auxiliary/agents/skills/` (directory
package with `SKILL.md`, or flat `<name>.md`). Populate merges into
that tree and never deletes foreign entries. Only the per-coder
`skills/` discovery symlinks are replaced on populate, so move any
custom skills out of `coders/*/skills/` first — or delete them if
vestigial. `project-triage` in per-coder `skills/` trees is retired
distributed content, not a custom skill: delete it outright, do not
rescue it. The same holds for retired distributed MCP servers —
`pyright` and `librovore` entries lingering in old configurations
are vestigial (both cut from the template in March) and should be
deleted on sight, not restored.

## Legacy real paths

Populate retargets a wrong symlink but only warns and skips a real
path. Before populating, check whether `.claude/`, `.opencode/`, and
root memory files are symlinks or legacy real directories/files: a
legacy real path blocks its managed symlink from materializing.
Remove legacy real paths by hand (after rescuing anything
project-owned).

## Rollback

- Recorded answers persist: re-running the update without the data
  file does NOT restore prior values — Copier keeps the recorded
  answers. To roll back the answers migration, read the prior value
  from version control without touching the worktree (checking it
  out would dirty the tree and trip the clean-tree gate), pass it
  back in as data, then re-run populate so generated output matches:

      PRIOR=$(git show <pre-update-ref>:.auxiliary/configuration/copier-answers--agents.yaml | grep instructions_target | awk '{print $2}')
      copier update --answers-file .auxiliary/configuration/copier-answers--agents.yaml --skip-answered --data instructions_target=$PRIOR
      agentsmgr populate project <source>/distribution <target>

- Populated content: first rescue any project-owned files from the
  managed trees — custom skills in `.auxiliary/agents/skills/`
  coexist with distributed ones and must be preserved — then delete
  the managed trees and re-populate.

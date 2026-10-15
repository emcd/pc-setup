# Project Guidance

Project-owned knowledge the generated `AGENTS.md` entrypoint must not own.
Structured tracking stays in `nb`.

## Purpose

PC Setup owns workstation bootstrap (Ubuntu), production Cistella
container images (shared base + per-harness images), and host mount
sources for seats. Cistella stays image-agnostic via `profile.image`;
agents run in `agentmux` tmux-backed seats whose profiles live in
`configuration/cistella/profiles/`.

## Tech Stack

Bash scripts (`scripts/`), rootless Podman (runc default, crun
available), Debian `trixie-slim` images, `nb` notebooks for tracking,
`agentmux` for multi-agent coordination, OpenSpec for proposals.

## Notes

- Component folders in `nb`: `coordination/general` (rolling handoff),
  `todos/images`, `reviews/`, plus per-area folders as needed.
- The production `agentmux` relay is this session's control plane: never
  restart it from here; the operator restarts it.
- Never push, merge, or enable timers without an explicit operator word.
  Review flow is tier-1 (Reviewer General) then tier-2 (Advisor) with
  `fixup!` commits; see @.auxiliary/agents/procedures/reviews.md.
- After a `:local` image retag, seats are recreated through the
  coordinator; this script never touches seats.
- Mount taxonomy and image contract: see root `README.md`.
- `nb edit` has no substring replace: `overwrite` replaces the whole
  note body, so always rewrite the full body.
- Use `rg --line-number --column` for precise MCP tool coordinates.

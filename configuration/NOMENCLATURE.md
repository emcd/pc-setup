# Seat and coder nomenclature

Operator-decided, 2026-11-07.

## Principles

1. Containerization by default. Bare names are the containerized slot
   (Cistella seat, YOLO or auto mode). Harnesses without a tested image yet
   keep local bodies under bare names temporarily until they containerize.
   No bare name means local forever.
2. `--` (double dash) separates the base from the specialization; `-`
   (single dash) only ever joins words inside one name. `X--Y` always parses
   as base `X`, specialization `Y`.
3. The `--specialization` layer is transitional. Once Cistella supports
   optional supplement/superposition overlays (e.g. Agentmux passing
   `--profile-superposition-optional
   ~/.config/cistella-superpositions/{{ project-name }}.toml`), most
   `--specialization` profiles dissolve into overlays.

## Cistella profiles

- `<image-name>` — generic seat on that image: `codex`, `muse`, `opencode`.
- `<image-name>--<specialization-name>` — specialized seat, e.g.
  `opencode-pandoc--litrpg`, `opencode--fleet-coordinator`,
  `opencode--cistella-maintainer`, `opencode--agentmux`,
  `opencode-pandoc--conlang`.

## Agentmux coders

- `<harness-name>` — containerized seat on the default image, transport tmux
  implicit: `claude`, `codex`, `muse`, `opencode`.
- `<harness-name>-<transport>` — e.g. `opencode-acp`; `opencode-pty` later.
- `<harness-name>--host-maintainer` — non-containerized, permission prompts
  in effect. For the operator's own session and the Cistella QA partner
  session only. Example: `opencode--host-maintainer`.
- `<harness-name>--<specialization-name>` — containerized seat on a chosen
  `opencode-*` profile (the coder picks whichever profile fits; there is no
  bare-compound coder name), e.g. `opencode--litrpg` (profile
  `opencode-pandoc--litrpg`), `opencode--cistella-maintainer`.

## Access rule

Read-write mounts on `~/.config/agentmux` (and `~/.config/cistella`) are
reserved for the fleet coordinator (`coordinator@infrastructure`).
Per-bundle coordinators keep read-only config.

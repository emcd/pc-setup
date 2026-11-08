# Design: containerized ComfyUI

## Context

One-off git clone on the host; no pinning, no GPU story, no shared access.
Stakeholders: operator (GUI user), LitRPG Assets Engineer (game-asset
consumer; output dir must be mountable in LitRPG containers), future
agent-managed image pipeline (MCP server talks HTTP to this server).
Constraint: usable via host browser BEFORE Cistella networking exists; join
the `ai-apps` network later without rework.

## Goals / Non-Goals

- Goals: pinned, rebuildable image; one-command run with GUI on host
  browser; host-owned models/output/workflows mounted in; GPU acceleration
  working on the GB10 host; documented path to `ai-apps` membership later.
- Non-Goals: Cistella profile/supplement wiring (tracked separately);
  model provisioning automation (document the expected host layout, don't
  fetch gigabytes at build time); auth (document, don't implement).

## Decisions

- **Pinned image, own tree (`images/comfyui/`), outside the seat refresh
  closure.** Rationale: ComfyUI + torch/CUDA move on a creative cadence, not
  the nightly drift cadence; manual bumps avoid surprise 10 GB rebuilds.
  Reuses the pin discipline (ref + sha256), not the refresh machinery.
- **Run helper script over compose/Nix.** A `scripts/run-comfyui` wrapper
  around one `podman run` line is auditable, needs no daemon or new
  toolchain, and matches the Steam-supplement pattern already in repo.
  Alternatives considered: compose file (rejected — daemon-adjacent state
  for a single container); Nix (rejected — new toolchain, CUDA-on-Nix pain,
  zero team experience).
- **Models/output/workflows as host mounts, never baked.** Rationale: keeps
  the image small and disposable; lets LitRPG mount the same output dir.
  Container holds code + deps only.
- **`--gpus all` + `-p 8188:8188`.** Rationale: NVIDIA container toolkit is
  already host-present; port publish gives the host browser the GUI with no
  display plumbing (ComfyUI is an HTTP server; the UI is a browser tab).
- **No auth in phase one; trusted-LAN assumption documented.** ComfyUI ships
  none; the helper binds loopback-plus-LAN publish and the doc states the
  reverse-proxy path for anything beyond.

## Risks / Trade-offs

- [Risk] torch/CUDA image layers are large (~10 GB with deps) → Mitigation:
  volume-mount the model weight bulk; image carries code + framework only.
- [Risk] Upstream ComfyUI moves fast; pins rot → Mitigation: manual,
  deliberate bumps with a smoke test (GUI loads, queue runs) per bump.
- [Risk] Custom-node sprawl recreates the fragile-clone problem inside the
  container → Mitigation: custom nodes are an explicit pinned list in the
  Containerfile, not ad-hoc installs; additions go through version bumps.
- [Risk] No auth → Mitigation: documented LAN-only posture; proxy later.

## Migration Plan

Build image, run helper, open GUI, run a queue-to-image smoke test; LitRPG
mounts the output dir into their seats; later, join `ai-apps` (name
`comfyui`) when Cistella networking lands — no rebuild needed. Rollback is
`podman stop/rm` plus rerun of the previous image tag.

## Open Questions

- Which ComfyUI ref + custom-node set seeds v1 (migrate from the throwaway
  clone — need its location/ref)?
- Which torch/CUDA release line to pin (match host driver 580.x)?

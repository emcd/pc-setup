# Proposal: containerized ComfyUI

## Why

ComfyUI today is a fragile throwaway git clone. LitRPG needs it as shared,
reproducible infrastructure (game assets now, agent-managed generation next),
and the operator wants the GUI against a running containerized server before
Cistella networking lands.

## What Changes

- New pinned ComfyUI image (`images/comfyui/`: ComfyUI ref + torch/CUDA pin
  with per-arch sha256, same discipline as seat images). NOT part of the
  nightly seat-image refresh closure (different cadence; manual version bumps).
- A small run helper (`scripts/run-comfyui`) encoding the day-to-day
  invocation: `--gpus all`, `-p 8188:8188`, volume mounts for models/output/
  workflows, restart policy. Host browser opens the GUI; no X11/Wayland
  involvement, no Cistella networking required for this phase.
- Mount contract for consumers: models and output live on the host and are
  mounted in, so the container stays disposable; LitRPG seats mount the same
  output dir (their Assets Engineer reviews this contract).
- No auth by default (ComfyUI has none): bind/publish plan documents the
  trusted-LAN assumption and the reverse-proxy path beyond it.

No BREAKING changes. Nothing in the seat fleet moves.

## Capabilities

### New Capabilities

- `comfyui-image`: reproducible ComfyUI server image plus the run helper and
  mount contract described above.

### Modified Capabilities

(none — new top-level area, no existing spec changes behavior)

## Impact

- New `images/comfyui/` (Containerfile + pins.sh), new `scripts/run-comfyui`,
  docs for the GUI workflow. GPU passthrough via the NVIDIA container toolkit
  already on the host. LitRPG Assets Engineer (`assets@litrpg`) is an early
  reviewer (output-dir mount contract).

# ComfyUI (pinned container)

Reproducible ComfyUI server for GUI use and agent-managed image generation.
Pinned: ComfyUI v0.44.0 (`2c75dc1`), torch 2.15.0 + torchao 0.18.0 +
torchvision 0.29.2 against cu130/CUDA 13, base
`nvidia/cuda:13.0.0-runtime-ubuntu24.04@sha256:95318ef...`.
See `pins.sh` for exact pins; bump there and rebuild.

## Run it

Interactive (foreground logs, Ctrl-C stops):

```
scripts/run-comfyui
```

Then open http://127.0.0.1:8188/ in a host browser. No Cistella
networking involved; no X11/Wayland plumbing (the UI is a web app).

Managed (restart on failure, journal logs, disabled by default):

```
systemctl --user enable --now comfyui.service
```

`scripts/run-comfyui` also creates the host data dirs on first run.

## Mounts (all host-owned, container stays disposable)

| Host | Container | Mode | Notes |
|---|---|---|---|
| `~/.local/share/comfyui/models` | `/app/ComfyUI/models` | rw | checkpoints, loras, vae, text encoders; manifest-driven downloads land here |
| `~/.local/share/comfyui/output` | `/app/ComfyUI/output` | rw | **shared with LitRPG seats** |
| `~/.local/share/comfyui/input` | `/app/ComfyUI/input` | rw | upload sources |
| `~/.local/share/comfyui/workflows` | `/app/ComfyUI/user/default/workflows` | rw | saved graphs (see provenance) |

## GPU

Needs the host CDI compat spec (`no-additional-gids-for-device-nodes`,
pinned via `NVIDIA_CTK_CDI_GENERATE_FEATURE_FLAGS`) plus
`--device nvidia.com/gpu=all --security-opt=label=disable` (both already in
the run helper and the unit). Verified: GB10 visible, torch CUDA live.

## Standing rules

- **Provenance.** A queued workflow is snapshotted/copied into the LitRPG
  manifest (or the workflows dir mounted read-only at queue time) — never
  rely on a mutable host file as the record of what ran.
- **Trusted LAN only.** ComfyUI has no auth; neither does its Manager HTTP
  API (an arbitrary-install surface). Both are LAN-only; a reverse proxy
  with auth sits in front of either before any wider exposure.
- **No baked models.** Anything downloaded (checkpoints, custom nodes via
  Manager) lands on mounted paths, never in the image.

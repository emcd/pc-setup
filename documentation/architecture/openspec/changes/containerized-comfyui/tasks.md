## 1. Change scaffolding and review

- [x] 1.1 Record proposal, design, specs, and tasks for containerized ComfyUI
- [ ] 1.2 LitRPG Assets Engineer (`assets@litrpg`) reviews mount contract and image scope
- [x] 1.3 Operator approves form factor (pinned container image; systemd unit runs the container, helper script covers setup + browser URL; no compose, no Nix)

## 2. Image

- [x] 2.1 v1 custom-node seed resolved: EMPTY set per Assets Engineer (klein 4B native core; Z-Image secondary)
- [x] 2.2 Create `images/comfyui/Containerfile` (pinned ComfyUI v0.44.0 ref, torch 2.15.0 + torchao 0.18.0 + torchvision 0.29.2 on cu130, CUDA 13.0 runtime base digest-pinned, no baked models, empty custom-node set v1)
- [x] 2.3 Create `images/comfyui/pins.sh` (ref + checksums + base digest)
- [x] 2.4 Build, serve, smoke test (HTTP 200, system_stats versions match, torch CUDA live on GB10)

## 3. Run helper and docs

- [x] 3.1 `scripts/run-comfyui` (foreground) + `comfyui.service` user unit (managed; disabled by default); both use `--device nvidia.com/gpu=all` + label disable
- [x] 3.2 `images/comfyui/README.md`: GUI workflow, trusted-LAN posture, provenance snapshot rule, Manager endpoint LAN-only
- [ ] 3.3 LitRPG mounts the output dir into their seats; verify shared visibility
- [ ] 3.4 Klein-4B load via manifest flow, on first real generation (gate carried explicitly open per assets@litrpg agreement 2026-11-08; server+torch+GPU already verified on GB10; Apache 2.0 weights, no license gate, multi-GB pull happens with first manifest)

## 4. Later (out of scope)

- [ ] 4.1 Join `ai-apps` as `comfyui` when Cistella networking lands (no rebuild)
- [ ] 4.2 Reverse proxy with auth if exposed beyond trusted LAN

## 1. Change scaffolding and review

- [x] 1.1 Record proposal, design, specs, and tasks for containerized ComfyUI
- [ ] 1.2 LitRPG Assets Engineer (`assets@litrpg`) reviews mount contract and image scope
- [ ] 1.3 Operator approves form factor (container image + run-helper script; no compose, no Nix)

## 2. Image

- [x] 2.1 v1 custom-node seed resolved: EMPTY set per Assets Engineer (klein 4B native core; Z-Image secondary)
- [ ] 2.2 Create `images/comfyui/Containerfile` (pinned ComfyUI ref, torch/CUDA pins with sha256 supporting Blackwell + torchao NVFP4 against driver 580.x, no custom nodes v1, no baked models)
- [ ] 2.3 Create `images/comfyui/pins.sh` (ref + checksums)
- [ ] 2.4 Build, serve, GUI smoke test (GUI loads, queue runs to image)

## 3. Run helper and docs

- [ ] 3.1 Create `scripts/run-comfyui` (`--gpus all`, `-p 8188:8188`, host mounts, restart policy)
- [ ] 3.2 Document the GUI workflow and the trusted-LAN posture
- [ ] 3.3 LitRPG mounts the output dir into their seats; verify shared visibility

## 4. Later (out of scope)

- [ ] 4.1 Join `ai-apps` as `comfyui` when Cistella networking lands (no rebuild)
- [ ] 4.2 Reverse proxy with auth if exposed beyond trusted LAN

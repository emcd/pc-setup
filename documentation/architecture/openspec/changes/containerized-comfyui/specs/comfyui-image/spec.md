# comfyui-image

Reproducible ComfyUI server image, run helper, and mount contract for GUI
and agent-managed image generation.

- The image SHALL pin its ComfyUI ref and torch/CUDA artifacts with
  checksums following the repo's existing pin discipline, and SHALL build
  from those pins without network-fetched mutable installers.
- The image SHALL NOT bake models, outputs, or workflows; those SHALL arrive
  via host mounts documented in the run helper.
- `scripts/run-comfyui` SHALL launch the server with GPU passthrough,
  published port 8188, and the documented mounts, such that the host
  browser reaches the GUI with no Cistella networking involved.
- The LitRPG output directory SHALL be mountable in LitRPG seats
  unchanged (same host path the helper mounts).

- **WHEN** the image builds from pins
- **THEN** `podman run` serves the API on 8188 and the GUI loads in a host browser

- **WHEN** a workflow is queued with outputs directed at the mounted output dir
- **THEN** result files appear on the host path visible to LitRPG seats

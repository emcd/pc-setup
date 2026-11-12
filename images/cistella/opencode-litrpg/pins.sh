# OPENCODE_* and PANDOC_* are duplicated from their owning lanes (D3):
# refresh discovery rewrites all owners atomically. PANDOC_* stays held
# notify-only. COMFY_* tooling is owned here. The browser-runtime system
# libraries float on trixie apt (lane-TeX precedent).
OPENCODE_VERSION=2.2.7
OPENCODE_SHA256_ARM64=7e74ceb64fe5704ff2fdef3dee45866efcb580d71f182a6cae29606cad1f8b52
OPENCODE_SHA256_AMD64=d65935464f93f07913633f977cb99723af64eeff6ae7a822722ce89bedabdd45
PANDOC_VERSION=3.1.13
PANDOC_SHA256_ARM64=678c09ac4227c88b491f6e75491e6da871fd08d79b8c0f0ee37b611f01ad3d25
PANDOC_SHA256_AMD64=db556c98cf207d2fddc088d12d2e2f367d9401784d4a3e914b068fa895dcf3f0
COMFY_MCP_VERSION=0.10.0
COMFY_CLI_VERSION=1.25.0

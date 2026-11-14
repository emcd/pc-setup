# OPENCODE_* and PANDOC_* are duplicated from their owning lanes (D3):
# refresh discovery rewrites all owners atomically. PANDOC_* stays held
# notify-only. COMFY_* tooling is owned here. The browser-runtime system
# libraries float on trixie apt (lane-TeX precedent).
OPENCODE_VERSION=2.3.0
OPENCODE_SHA256_ARM64=be30066353bb592c43919b31072ff4099e069636c31a16806b088737e0287cea
OPENCODE_SHA256_AMD64=408f854b5fac7857a3b4df4e783d3a8b70f5cc8c7c3187aac09c5be0576c14ae
PANDOC_VERSION=3.1.13
PANDOC_SHA256_ARM64=678c09ac4227c88b491f6e75491e6da871fd08d79b8c0f0ee37b611f01ad3d25
PANDOC_SHA256_AMD64=db556c98cf207d2fddc088d12d2e2f367d9401784d4a3e914b068fa895dcf3f0
COMFY_MCP_VERSION=0.10.0
COMFY_CLI_VERSION=1.25.0

# OPENCODE_* and PANDOC_* are duplicated from their owning lanes (D3):
# refresh discovery rewrites all owners atomically. PANDOC_* stays held
# notify-only. COMFY_* tooling is owned here. The browser-runtime system
# libraries float on trixie apt (lane-TeX precedent).
OPENCODE_VERSION=2.3.2
OPENCODE_SHA256_ARM64=91a937129efdae8eb8c0c5018ae533f9f35117f26ffd9a4d1f7a5f9da1e69306
OPENCODE_SHA256_AMD64=845468e35aa5a2b574945a0b96675e64c604f5279ced9aa7245068d8c0b6f6bb
PANDOC_VERSION=3.1.13
PANDOC_SHA256_ARM64=678c09ac4227c88b491f6e75491e6da871fd08d79b8c0f0ee37b611f01ad3d25
PANDOC_SHA256_AMD64=db556c98cf207d2fddc088d12d2e2f367d9401784d4a3e914b068fa895dcf3f0
COMFY_MCP_VERSION=0.10.0
COMFY_CLI_VERSION=1.25.0

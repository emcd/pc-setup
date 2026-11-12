#!/bin/sh
# Fragment: comfy-tools — ComfyUI MCP server + CLI for agent-driven
# generations. uv tool shims land in /usr/local/bin (same store as the
# base tools); COMFY_BIN=/usr/local/bin/comfy is the stable MCP path.
# Inputs (env): COMFY_MCP_VERSION, COMFY_CLI_VERSION. Needs uv plus the
# UV store env vars (UV_PYTHON_INSTALL_DIR, UV_TOOL_DIR, UV_TOOL_BIN_DIR),
# which the consuming lane declares since ENV is image metadata.
set -eu
: "${COMFY_MCP_VERSION:?comfy-tools requires COMFY_MCP_VERSION}"
: "${COMFY_CLI_VERSION:?comfy-tools requires COMFY_CLI_VERSION}"
uv tool install "comfy-mcp==${COMFY_MCP_VERSION}"
uv tool install "comfy-cli==${COMFY_CLI_VERSION}"

#!/bin/sh
# Fragment: harness-codex — verified Codex binary into /usr/local/bin.
# Inputs (env): TARGETARCH (arm64|amd64), CODEX_VERSION,
# CODEX_SHA256_ARM64, CODEX_SHA256_AMD64. Needs curl + tar in image.
set -eu
: "${TARGETARCH:?harness-codex requires TARGETARCH}"
: "${CODEX_VERSION:?harness-codex requires CODEX_VERSION}"
case "${TARGETARCH}" in
    arm64) codex_plat=aarch64-unknown-linux-musl; codex_sha="${CODEX_SHA256_ARM64:?harness-codex requires CODEX_SHA256_ARM64}" ;;
    amd64) codex_plat=x86_64-unknown-linux-musl; codex_sha="${CODEX_SHA256_AMD64:?harness-codex requires CODEX_SHA256_AMD64}" ;;
    *) echo "error: unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;;
esac
curl --fail --location --show-error --silent --output /tmp/codex.tar.gz \
    "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-${codex_plat}.tar.gz"
echo "${codex_sha}  /tmp/codex.tar.gz" | sha256sum --check --strict
mkdir --parents /tmp/harness-fetch
tar --extract --gzip --file /tmp/codex.tar.gz --directory /tmp/harness-fetch
install --mode=0755 "/tmp/harness-fetch/codex-${codex_plat}" /usr/local/bin/codex
rm -rf /tmp/codex.tar.gz /tmp/harness-fetch

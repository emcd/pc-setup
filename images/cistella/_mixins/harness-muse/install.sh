#!/bin/sh
# Fragment: harness-muse — verified Muse binary into /usr/local/bin.
# Inputs (env): TARGETARCH (arm64|amd64), MUSE_VERSION,
# MUSE_SHA256_ARM64, MUSE_SHA256_AMD64. Needs curl in image.
set -eu
: "${TARGETARCH:?harness-muse requires TARGETARCH}"
: "${MUSE_VERSION:?harness-muse requires MUSE_VERSION}"
case "${TARGETARCH}" in
    arm64) muse_file=muse-aarch64-linux; muse_sha="${MUSE_SHA256_ARM64:?harness-muse requires MUSE_SHA256_ARM64}" ;;
    amd64) muse_file=muse-x86-linux; muse_sha="${MUSE_SHA256_AMD64:?harness-muse requires MUSE_SHA256_AMD64}" ;;
    *) echo "error: unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;;
esac
curl --fail --location --show-error --silent --output /tmp/muse.bin \
    "https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=${MUSE_VERSION}&file=${muse_file}"
echo "${muse_sha}  /tmp/muse.bin" | sha256sum --check --strict
install --mode=0755 /tmp/muse.bin /usr/local/bin/muse
rm -f /tmp/muse.bin

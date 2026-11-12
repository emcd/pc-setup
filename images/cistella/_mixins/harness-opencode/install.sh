#!/bin/sh
# Fragment: harness-opencode — verified OpenCode binary into /usr/local/bin.
# Inputs (env): TARGETARCH (arm64|amd64), OPENCODE_VERSION,
# OPENCODE_SHA256_ARM64, OPENCODE_SHA256_AMD64. Needs curl + tar in image.
# OpenCode 2 ships as npm platform packages, not GitHub release assets:
# the upstream project tags V2 without publishing release objects, so the
# registry is the only pinnable artifact source. Each platform package
# contains one native binary at package/bin/opencode and declares no
# install script, so nothing executes at build time.
set -eu
: "${TARGETARCH:?harness-opencode requires TARGETARCH}"
: "${OPENCODE_VERSION:?harness-opencode requires OPENCODE_VERSION}"
case "${TARGETARCH}" in
    arm64) oc_pkg=cli-linux-arm64; oc_sha="${OPENCODE_SHA256_ARM64:?harness-opencode requires OPENCODE_SHA256_ARM64}" ;;
    amd64) oc_pkg=cli-linux-x64; oc_sha="${OPENCODE_SHA256_AMD64:?harness-opencode requires OPENCODE_SHA256_AMD64}" ;;
    *) echo "error: unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;;
esac
curl --fail --location --show-error --silent --output /tmp/opencode.tgz \
    "https://registry.npmjs.org/@opencode/${oc_pkg}/-/${oc_pkg}-${OPENCODE_VERSION}.tgz"
echo "${oc_sha}  /tmp/opencode.tgz" | sha256sum --check --strict
mkdir --parents /tmp/harness-fetch
tar --extract --gzip --file /tmp/opencode.tgz --directory /tmp/harness-fetch \
    --strip-components=2 package/bin/opencode
install --mode=0755 /tmp/harness-fetch/opencode /usr/local/bin/opencode
rm -rf /tmp/opencode.tgz /tmp/harness-fetch

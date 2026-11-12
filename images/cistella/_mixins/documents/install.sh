#!/bin/sh
# Fragment: documents — verified pandoc binary plus the TeX toolchain.
# Inputs (env): TARGETARCH (arm64|amd64), PANDOC_VERSION,
# PANDOC_SHA256_ARM64, PANDOC_SHA256_AMD64. Needs curl + tar + apt.
# Expects DEBIAN_FRONTEND=noninteractive in the environment.
# Pandoc publishes per-arch Linux release tarballs holding bin/pandoc,
# bin/pandoc-lua and bin/pandoc-server. Only the pandoc binary is
# installed; nothing executes at build time. The TeX package set floats
# on trixie apt (no pins), same precedent as the base distro baseline.
set -eu
: "${TARGETARCH:?documents requires TARGETARCH}"
: "${PANDOC_VERSION:?documents requires PANDOC_VERSION}"
case "${TARGETARCH}" in
    arm64) pan_arch=arm64; pan_sha="${PANDOC_SHA256_ARM64:?documents requires PANDOC_SHA256_ARM64}" ;;
    amd64) pan_arch=amd64; pan_sha="${PANDOC_SHA256_AMD64:?documents requires PANDOC_SHA256_AMD64}" ;;
    *) echo "error: unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;;
esac
script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# Read and validate the package list BEFORE any apt mutation: grep runs
# in an explicit status-checked statement (not inside an && chain or
# command substitution whose status apt could mask), so a missing,
# unreadable, or empty list fails here with no apt side effects.
if ! pkg_list="$(grep -v '^#' "${script_dir}/packages.txt")"; then
    echo "error: documents: cannot read packages.txt" >&2
    exit 1
fi
if [ -z "${pkg_list}" ]; then
    echo "error: documents: packages.txt is empty" >&2
    exit 1
fi
# Each apt step is its own statement so set -e aborts on the first failure.
apt-get update
# shellcheck disable=SC2086
apt-get install --yes --no-install-recommends ${pkg_list}
rm -rf /var/lib/apt/lists/*
curl --fail --location --show-error --silent --output /tmp/pandoc.tgz \
    "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${pan_arch}.tar.gz"
echo "${pan_sha}  /tmp/pandoc.tgz" | sha256sum --check --strict
mkdir --parents /tmp/pandoc-fetch
tar --extract --gzip --file /tmp/pandoc.tgz --directory /tmp/pandoc-fetch \
    --strip-components=2 "pandoc-${PANDOC_VERSION}/bin/pandoc"
install --mode=0755 /tmp/pandoc-fetch/pandoc /usr/local/bin/pandoc
rm -rf /tmp/pandoc.tgz /tmp/pandoc-fetch

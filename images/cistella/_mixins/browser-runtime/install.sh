#!/bin/sh
# Fragment: browser-runtime — Playwright/Chromium system libraries.
# Inputs: none versioned; the 13 libraries float on trixie apt (lane-TeX
# precedent). Needs apt. Expects DEBIAN_FRONTEND=noninteractive.
set -eu
script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# Read and validate the package list BEFORE any apt mutation: grep runs
# in an explicit status-checked statement (not inside an && chain or
# command substitution whose status apt could mask), so a missing,
# unreadable, or empty list fails here with no apt side effects.
if ! pkg_list="$(grep -v '^#' "${script_dir}/packages.txt")"; then
    echo "error: browser-runtime: cannot read packages.txt" >&2
    exit 1
fi
if [ -z "${pkg_list}" ]; then
    echo "error: browser-runtime: packages.txt is empty" >&2
    exit 1
fi
# Each apt step is its own statement so set -e aborts on the first failure.
apt-get update
# shellcheck disable=SC2086
apt-get install --yes --no-install-recommends ${pkg_list}
rm -rf /var/lib/apt/lists/*

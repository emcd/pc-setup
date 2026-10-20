## 1. Image and pins

- [x] 1.1 Rewrite the OpenCode fetch stage to pull the npm platform package for `TARGETARCH` (`@opencode/cli-linux-arm64`, `@opencode/cli-linux-x64`), verify the pinned sha256, and install `package/bin/opencode` to `/usr/local/bin/opencode`
- [x] 1.2 Pin `OPENCODE_VERSION=2.0.32` with per-arch sha256 pins for the npm platform tarballs
- [x] 1.3 Confirm the build executes no install script and the image reports the pinned version

## 2. Refresh track

- [x] 2.1 Replace the GitHub `releases/latest` OpenCode lookup with the npm `latest` dist-tag of `@opencode/cli`, resolving each platform tarball from the registry (fail closed on shape drift)
- [x] 2.2 Update the script's policy header to describe the npm channel for OpenCode
- [x] 2.3 Confirm `refresh-images check` reports the image converged against the new pins

## 3. Fixture tests

- [x] 3.1 Add npm registry fixtures to `scripts/test-refresh-images` (channel document, per-platform version document, tarball bytes) and repoint the OpenCode drift cases at them
- [x] 3.2 Add coverage for the new failure paths (malformed channel document, missing platform package, tarball fetch failure)
- [x] 3.3 Run the full suite, `bash -n`, and shellcheck clean

## 4. Docs and spec sync

- [x] 4.1 Document the OpenCode npm channel in the README refresh policy
- [x] 4.2 Sync the `agent-images` delta into the main spec and archive the change
- [x] 4.3 Update task statuses in this change with each completing commit

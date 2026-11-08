# opencode-litrpg-image

LitRPG-only seat image: the opencode harness via the pandoc lane plus the Playwright system libraries, for browser-automation and handbook seats.

- The image SHALL layer `FROM localhost/cistella/opencode-pandoc:local` and add libxcomposite1, libxdamage1, libxfixes3, libxrandr2, libasound2t64, libatk1.0-0t64, libatk-bridge2.0-0t64, libatspi2.0-0t64, libcups2t64, libdbus-1-3, libgbm1, libpango-1.0-0, and libxkbcommon0 via trixie apt (floating, no version pins).
- The image SHALL carry a pins file following the existing track shape (present even when no versioned inputs exist, so the fingerprint covers the layer).
- Refresh drift detection SHALL cover the new track with no held pins; the effective fingerprint SHALL cover the base+opencode+pandoc closure plus the layer's own recipe, so any ancestor change rebuilds it.
- `scripts/build-image` and `scripts/validate-image` SHALL accept `opencode-litrpg` (parents-first ordering with `--skip-parents` support; presence assertions for pandoc plus the 13 tool binaries). The fixture suite SHALL cover the new track in the standard lists, skeleton, and fingerprint-want computations.
- The `opencode-pandoc--litrpg` Cistella profile SHALL name `cistella/opencode-litrpg:local`. No coder changes (the `opencode--litrpg` coder already wraps that profile).

- **WHEN** `scripts/build-image opencode-litrpg` runs without local parent images to layer on
- **THEN** it builds base, then opencode, then opencode-pandoc, then the litrpg layer (parents from cache in standalone mode)

- **WHEN** `scripts/validate-image opencode-litrpg` runs after a successful build
- **THEN** pandoc and all 13 tool binaries resolve at their expected paths

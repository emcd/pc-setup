# No versioned inputs: the Playwright system libraries float on trixie apt
# (lane-TeX precedent). The closure fingerprint covers this file plus the
# Containerfile plus the full base+opencode+pandoc parent chain, so any
# ancestor change still rebuilds this layer.

# Migration receipt: flat composition rebuild

Baseline = pre-flat `:local` images (linear lanes, Nov-10 refresh).
Flat = rebuilt `FROM localhost/cistella/base:local` + fragments.

## Baseline (Nov-10 linear lanes; images verified present with Nov-10 timestamps and per-image refresh labels)

| Image | Size | Layers | Key payload (measured version + sha) |
|---|---|---|---|
| base | 1.77 GB | 4 | — |
| opencode | 1.73 GB | 5 | opencode v2.2.6 `ce4f5e75…` |
| codex | 1.78 GB | 5 | codex-cli 0.167.0 `2fe94d84…` |
| muse | 2.05 GB | 5 | muse 1.4.14 `3dc39b8f…` |
| opencode-pandoc | 2.29 GB | 7 | pandoc 3.1.13 `1f40a51c…`, texlive-xetex `2024.20250309-1`, fonts-dejavu-core `2.37-8` |
| opencode-litrpg | 2.91 GB | 9 | comfy-mcp `2dc9af2c…` (comfy-cli 1.25.0) |

## Flat (rebuilt Nov 11–12 from final reviewed recipes, validated green)

| Image | Size | Layers | Payload shas | Delta vs baseline |
|---|---|---|---|---|
| opencode | 1.73 GB | 6 | opencode v2.2.7 `c577783e…` (upstream bump from baseline v2.2.6; correct per current pins) | 0 GB, +1 layer (fragment COPY+RUN vs COPY) |
| codex | 1.78 GB | 6 | codex-cli 0.167.2 (upstream bump from baseline 0.167.0; pins match official GitHub release assets) | 0 GB, +1 layer |
| muse | 2.05 GB | 6 | muse 1.4.15 `d0760247…` (upstream bump from baseline 1.4.14; correct per current pins) | 0 GB, +1 layer |
| opencode-pandoc | 3.03 GB | 8 | pandoc `1f40a51c…` identical (3.1.13), texlive-xetex `2024.20250309-1` identical, fonts-dejavu-core `2.37-8` identical | +0.74 GB virtual, +1 layer (narrow COPY) |
| opencode-litrpg | 4.02 GB | 11 | comfy-mcp `2dc9af2c…` identical, dejavu faces 8, all lane tools present | +1.11 GB virtual, +2 layers (narrow COPY) |

Wall time (approx, TeX-dominated as before): harness lanes ~1 min each;
pandoc ~5 min; litrpg ~3 min.

## Equivalence statements (confirmed Nov 11–12, epochs explicit)

Baseline = Nov-10 linear-lane images (verified Created 2026-11-10,
proper refresh labels). Flat = current `:local` images (verified
converged via `refresh-images check`, exit 0). Version drift between
the eras is upstream-team/channel activity, not construction change;
it is itemized per payload below rather than folded into any
identity claim.

- Direct payloads, same version both sides, byte-identical shas
  (measured with `sha256sum` inside each image):
  `pandoc` 3.1.13 (`1f40a51c…`), `comfy-mcp` + `comfy`
  (`2dc9af2c…`, `comfy --version` 1.25.0 on both).
- Direct payloads with intentional upstream version bumps between
  eras (NO identity claim; flat binaries verified correct per
  current pins at build time, and `validate-image` asserts each
  reported version): opencode v2.2.6 → v2.2.7, codex-cli
  0.167.0 → 0.167.2 (pins match the official GitHub release
  assets), Muse 1.4.14 → 1.4.15.
- TeX/apt sets: identical package lists AND identical resolved versions
  (full `dpkg -l` manifests byte-identical for both composed finals;
  saved as `evidence/dpkg-*.txt`): texlive-xetex `2024.20250309-1`,
  texlive-latex-extra `2024.20250309-2`,
  texlive-latex-recommended `2024.20250309-1`,
  texlive-fonts-recommended `2024.20250309-1`, lmodern `2.005-1`,
  poppler-utils `25.03.0-5+deb13u4`, fonts-dejavu-core `2.37-8`;
  dejavu face count 8 unchanged.
- DISCLOSED (not hidden): unpinned TRANSITIVE uv dependencies of the
  comfy tools floated between builds (uv resolves latest at install
  time, same precedent as floating trixie apt): installed
  `annotated_doc` 0.0.5 → 0.0.6, `markdown_it_py` 4.2.0 → 4.3.0,
  plus `posthog` content changes, all inside the comfy-cli tool venv
  (base-image tool venvs still carry the older set). Direct pins
  (`COMFY_MCP_VERSION`, `COMFY_CLI_VERSION`) and tool behavior are
  unchanged and green. Transitive lockfiles are an explicit
  non-goal of this change (consistent with floating apt/TeX inputs);
  file as follow-up if the operator wants them pinned.
- Lane layer tar comparison (pandoc, baseline `:previous` vs flat
  `:local`, base layers excluded): flat lane tar 908,118,016 bytes vs
  baseline lane tars 908,115,456 bytes total (Δ 2.5 KB = tar padding
  plus one `tmp/.wh.mixins` whiteout marker). File sets: zero files
  missing from flat; only additions are the whiteout marker and one
  dir entry. Same-path files: all identical except 22 files with
  byte-level install-timestamp noise (TeX `.fmt` format files, apt log).
  Mixins sources persist as whiteout-obscured lower layers (own
  source, already in-repo, negligible bytes, no runtime content).
- LitRPG lane tar comparison (same method): flat 1,918,772,061 bytes
  vs baseline 1,918,649,521 bytes (Δ +122 KB, +0.006%). File sets
  equal modulo uv cache-hash directory names; the only content
  differences beyond TeX timestamp noise are the disclosed transitive
  uv bumps above. No other new, missing, or changed files.
- Fetch stages consolidated into fragment install scripts with identical
  URLs, `sha256sum --check --strict` verification, and temp cleanup;
  final layers carry only the installed payload (no residue). Design D5
  records the explicit fragment-direct exception with this evidence bar.
- No image-name fallback: every `COPY --from=mixins` resolves the declared
  local `--build-context` (builds fail without it).
- Virtual-size display deltas (+0.74 / +1.11 GB): the stored-layer
  cost delta is UNESTABLISHED. Owner-reported scoped facts retained:
  identical pandoc/comfy payload shas and package versions, lane-tar
  file-set comparison (pandoc flat lane tar 908,118,016 bytes vs
  baseline 908,115,456; litrpg flat 1,918,772,061 vs baseline
  1,918,649,521), and the disclosed uv transitive bumps. These file
  facts do NOT establish that the virtual-size growth is merely layer
  attribution or that no new stored bytes exist: identical TeX payload
  separately encoded in different final layers can add unique storage,
  and no per-layer union-vs-shared accounting (referenced layer
  IDs/referrers/sizes, or read-only storage SHARED/UNIQUE output) is
  provided here. The earlier claim that file-set equality accounts for
  every byte is WITHDRAWN. Operator decision (2026-11-12): obligation
  ACCEPTED AS UNFULFILLED; capacity risk carried openly — any missing
  content will surface via consumer use.
- Independence proof: `opencode-pandoc` rebuilt and validated green with
  NO `opencode:*` tag present at all — only `base:local` referenced.
  Tag restored to the validated flat image afterwards. Isolated-storage
  rebuilds (separate graph root, production tags untouched): see below.

## Image identities

| Image | Baseline `:previous` ID (Nov-10 outputs) | Flat `:local` ID (this change) | Layers base → flat |
|---|---|---|---|
| base | `60a8167e94f5b3fea6c9bec141b1b298e357ffd98c222fc08b53eb2c0b3499d1` (unchanged by this change) | same | 4 → 4 |
| opencode | `245636882e85b79e46b37d98db38bc8c58de256598bb35f1a1cea33dca095c31` | `c06f006932a4815a6e551e3d02cee0b05174a0717a0d5ebc697dcc878a84d118` | 5 → 6 |
| codex | `4c1ba5facc35684224c6a572fa5c2db05c5ad85274a6dd01b7ef46f1953dbb84` | `4441cbc3e875a30de0a1528e32fad0ecee96be21b5acf92fc7c01d8df55d55ca` | 5 → 6 |
| muse | `620ba40c78800288c976afed68e83d9835138fd51722ff40ce89cc404b3fe9ef` | `fe79534ebe1c76957d37c5f7cf8dace24420c5246f5ac3bf1871b2539ee2374d` | 5 → 6 |
| opencode-pandoc | `04ac4026caa56de62e74f0e24954bc02dabacda977fa00d2ca59dd5f8c4767c4` | `9e47c3e43119aaefdadf99f4df0915ef1f9688d9829431279ca0616ce2d51f32` | 7 → 8 |
| opencode-litrpg | `3992801eea3deb004a22e6b72e62aa3af8b11402505f67818d400e185d6543df` | `b0b9659f21d786f8bf9a679c2fd93ca8bb27e53a230966773e43b7145450fe83` | 9 → 11 |

All compared images share the identical 4 base-layer digests listed
below (verified by inspect on both eras); the older base tag
`d8f8524754` (pre-Nov-10) takes no part in this comparison.
`codex` differs intentionally between eras: baseline `0.167.0`
(`2fe94d84…`), flat `0.167.2` (upstream releases; pins match the
official GitHub release assets). All compared payloads besides the opencode/codex/muse upstream bumps itemized above are
same-version on both sides; see the uv transitive-drift disclosure
above for the explicitly non-pinned exceptions.

Layer growth (+1 harness, +1 pandoc, +2 litrpg) is the narrow per-file
COPY form (each declared input copied explicitly); no content change.
Every flat final carries its own computed `pc-setup.refresh-pins`
label (verified distinct per image); the label a manual build inherits
from base is stale by design and converges on the next refresh.

Base layers (4 digests) are shared verbatim across every flat final:
`04e61ff9ed2c84e88795bf7562d69d0980188e2bb6d6152d6fe721383e10db9e`,
`a4a33251d45f987e383362272a659f4d82df64ecf3624b1693e36483b7538f8e`,
`bdb251b47ae94442c4a49c62fdee30c693a38f397ad02e9b667bc4d0096da85c`,
`9968d079430243678f05710d98f9b445eefd06bbaf895e931961bbb8f6a2bafe`.
Lane digests differ (expected: different build steps/timestamps) —
content equality is established by the file/binary/package evidence
above, not by digest identity, and no byte-identical image claim is
made. Full inspected image IDs (refresh labels verified distinct
per image as stated above; label values not reproduced here):

```
base:            60a8167e94f5b3fea6c9bec141b1b298e357ffd98c222fc08b53eb2c0b3499d1
opencode:        c06f006932a4815a6e551e3d02cee0b05174a0717a0d5ebc697dcc878a84d118
codex:           4441cbc3e875a30de0a1528e32fad0ecee96be21b5acf92fc7c01d8df55d55ca
muse:            fe79534ebe1c76957d37c5f7cf8dace24420c5246f5ac3bf1871b2539ee2374d
opencode-pandoc: 9e47c3e43119aaefdadf99f4df0915ef1f9688d9829431279ca0616ce2d51f32
opencode-litrpg: b0b9659f21d786f8bf9a679c2fd93ca8bb27e53a230966773e43b7145450fe83
```

Isolated-storage independence (alt graph root at a scratch dir,
production tags untouched; only `base:local` loaded in):
`opencode-pandoc` built + validated green (image `9cb448d6a140`),
`opencode-litrpg` built + validated green (image `bbb4515489bd`),
with no other tags present in that storage. Both composed finals
therefore build from declared inputs alone; harness-only finals share
the identical single-fragment pattern (base-only FROM, verified fetch
in fragment). Alt-root images use the final reviewed recipes
(narrow COPY, fail-fast fragments). Full alt IDs:
`9cb448d6a140121d747160de740ce5693ab2ec77f1cd21499045f8d2ca8b3dec`,
`bbb4515489bd1b9277ea6c9f3f4f51ef80ac23348890f7f4319692e111da1478`.

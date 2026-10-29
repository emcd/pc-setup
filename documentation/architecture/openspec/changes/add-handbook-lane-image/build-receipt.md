# Build receipt: opencode-pandoc lane image and closure refresh

Owner-measured 2026-11-03 on host spark-f980 (aarch64), `podman image
inspect` output copied verbatim below. Not independently verified.
Answers the D2 design requirement (validated built image digest with
resolved package/font versions and parent image digests recorded
alongside it) with a durable record rather than prose.

## Parentage (measured, not inferred)

Every image's RootFS layer list is recorded verbatim. All five images
share the same first four layers (the base image's full layer set);
opencode, codex, and muse each add exactly one harness layer; the lane
image adds exactly two (TeX/toolchain layer plus the pandoc binary
layer) on top of opencode's five. Shared layer digests are the
parentage proof; the FROM lines in the Containerfiles are the
structural intent.

### cistella/base:local
- image ID: 87cc8760eeb8092551a81c7ad4152e6ce8fb8dd1d275b7a0aabc9f69d510411c
- manifest digest: sha256:685cb270ce5b6800aaf849f43cf4745cdadb3b2aa26c563c2bcad0af2356f577
- size (bytes, as reported): 1677951352
- layers:
  - sha256:685889762157cefb6370119253b3c709f70bb2622402052065c92243e3d9105f
  - sha256:5664dcbd2bccf594850ad9e6e8b9bf996512e1e413ec02b490da43aaa06df892
  - sha256:dac570c5e969425eec1113c58b7769b5f0b20887a551bb0ae6dbf5e8b4adadcb
  - sha256:0ba809df304cedd4aa4927b9cd8174dfe782469c7a68596a097e6b7c3f1cf6dc

### cistella/opencode:local
- image ID: c833fb4bf1593a9dec261ec1bf06212818f63a8dfb66e0b87431b32b95bcf1e1
- manifest digest: sha256:30d0f0ee1378b0cb8aff152fece6422e601dc0203acffba5d5ce83c0cf75c253
- size (bytes, as reported): 1619797049
- layers: base's four plus
  - sha256:f6ce4ad6629e14f251d45b447d3befd9f27ad920e572baea712a1ac8b08ee8f1

### cistella/codex:local
- image ID: 705a9397ac4d6d258b43ad2ce5500c680d19a212b20af7876c4a8e9d783f0d3e
- manifest digest: sha256:cada805bf7102db9eaa8b37c84a1a60b74709b2057ca002ff3dee194224bb528
- size (bytes, as reported): 1678028855
- layers: base's four plus
  - sha256:846d81d39c0fa1b001773c3da5818ed3f9c57f028b9790ba8162d822320dc384

### cistella/muse:local
- image ID: 1b4c055309128c3c9d80c247b5e4e2083fa0050a736db601fa98ec1976dd5173
- manifest digest: sha256:58ac1431de1bd0f4f6bbf07279f22af267716bdf9ed644cc9ae49b99c6ea0861
- size (bytes, as reported): 1865990198
- layers: base's four plus
  - sha256:d07eff398925119d5a5c2e32d076abf8f8c77054b12b1718b7a0f288d63311d3

### cistella/opencode-pandoc:local
- image ID: 328c92eadeb6c98a13f3041b875131e5c19239cf66399cb5170a06f349f0aef4
- manifest digest: sha256:91f69a8a681a931bf2658d84085446d0bb6e11dca74c29d8664b18a50438f1ab
- size (bytes, as reported): 2197484393
- layers: opencode's five plus
  - sha256:818e20dcc9ad28d901b7f9a8f099f934abb6186c7a25f6c720afc14ca499013a
  - sha256:ea06519b1a9dcd17ddfc1deec5d84ccf0193bf003c6e704752bc218d1dec1c0f

## Resolved toolchain (from the built lane image, `dpkg -l` + binaries)

- pandoc 3.1.13 (verified `pandoc --version`; pinned upstream tarball)
- texlive-xetex, texlive-latex-recommended, texlive-fonts-recommended,
  texlive-latex-extra, texlive-latex-base, texlive-base: 2024.20250309-1
  (latex-extra: 2024.20250309-2)
- lmodern 2.005-1 (required: pandoc's default template loads
  `lmodern.sty`), fonts-dejavu-core 2.37-8, fontconfig 2.15.0-2.3,
  poppler-utils 25.03.0 (pdftotext 25.03.0)
- 8 DejaVu entries in `fc-list`

## Validation evidence on this build set

- `validate-image` green on all five images, including the lane
  end-to-end check: representative markdown document built with the
  lane's exact invocation (`pandoc input.md -o output.pdf --toc
  --toc-depth=2 --pdf-engine=xelatex`); `pdftotext` output contains the
  em-dash and the arrow; the subsection heading occurs >= 2 times
  (body plus TOC entry; a no-toc control build yields exactly 1);
  a table cell value is present; `pdffonts` shows every font
  `yes yes yes`.
- Fixture suite 66/66 green (held notify-only within- and above-series,
  missing-parent failure, parent-present build, inherited rebuilds,
  closure restore on child validation failure, recipe-only rebuilds).
- Nightly scheduled runs exit 0 (Nov 1: base label convergence after
  the single-writer fix; pandoc and pre-commit holds notify-only).

## Explicitly unresolved: base/opencode reported-size relationship

The lane-over-opencode delta (~560 MB from reported sizes) is
consistent with the two added layers and is accepted as the lane cost.
But `cistella/base:local` reports 1677951352 bytes while
`cistella/opencode:local` -- which contains the identical four base
layers plus one more -- reports 1619797049 bytes. That arithmetic does
not reconcile from the recorded data; dedup, compression, and whiteout
accounting are hypotheses, not measurements. Sizes above are
as-reported `Size` fields, not RAM and not per-seat copies (layers are
shared between images and seats). No new build is commissioned to
chase this; the discrepancy is flagged for an explicit
operator/Tier-2 decision on whether the receipt requirement needs more
than the layer-digest parentage plus as-reported sizes recorded here.

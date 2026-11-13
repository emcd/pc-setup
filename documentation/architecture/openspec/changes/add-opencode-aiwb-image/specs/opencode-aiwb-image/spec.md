# opencode-aiwb-image Specification

## Purpose
Lean ai-experiments seat image: opencode harness plus browser-runtime system libraries for playwright MCP headless Chromium, with no documents payload.

## ADDED Requirements
### Requirement: Independent aiwb final from base and shared fragments
The `opencode-aiwb` final SHALL compose only the shared base image and its declared fragment inputs. It SHALL NOT reference any other final lane and SHALL carry no documents payload.

#### Scenario: aiwb build carries capability without documents
- **WHEN** `scripts/build-image opencode-aiwb` succeeds
- **THEN** the image provides the pinned opencode binary and browser automation support, and provides no pandoc binary and no TeX packages

#### Scenario: No lane-to-lane ancestry
- **WHEN** the aiwb final is built with only the base tag present
- **THEN** the build succeeds from declared inputs alone

### Requirement: Browser capability validated as loadability
`scripts/validate-image opencode-aiwb` SHALL prove all declared browser-runtime dependencies loadable via dynamic loader plus a negative control. It SHALL NOT launch a browser.

#### Scenario: Library load proof
- **WHEN** `scripts/validate-image opencode-aiwb` runs green
- **THEN** every declared browser dependency loads and a bogus name fails the negative control

### Requirement: Refresh track with closure discipline
Refresh SHALL fingerprint the aiwb closure including base inputs, rebuild the final when stale, roll back its closure on failure, and treat the aiwb `OPENCODE_*` duplicate as a non-held owner: version and checksum disagreement reports drift in check and repairs every owner transactionally in apply, with all-owner fan-out on channel movement. A missing `:local` tag SHALL be bootstrapped by a first standalone build and validation before refresh manages the lane.

#### Scenario: Shared fragment edit stales all consumers
- **WHEN** a shared fragment consumed by aiwb changes in a way that alters fingerprints
- **THEN** aiwb and every other consuming final go stale while non-consuming finals remain converged

#### Scenario: Lane-only edit stales only aiwb
- **WHEN** only aiwb-owned inputs change
- **THEN** aiwb goes stale while all other finals remain converged

#### Scenario: Divergent aiwb duplicate is repaired
- **WHEN** the aiwb `OPENCODE_*` duplicate disagrees with the canonical tuple in version or checksums while upstream is unchanged
- **THEN** check reports drift instead of converging, and apply repairs every owner transactionally

#### Scenario: Channel movement fans out to all owners
- **WHEN** the OpenCode channel publishes a new version
- **THEN** discovery updates every OpenCode-consuming final's pins including aiwb, and rebuilds each stale final

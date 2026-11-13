# agent-images Delta: opencode-aiwb track

## ADDED Requirements

### Requirement: Tooling accepts the aiwb final
`scripts/build-image`, `scripts/validate-image`, and `scripts/refresh-images` SHALL accept `opencode-aiwb` with the same flat-composition semantics as the existing independent finals: named local mixin context with narrow COPY of declared inputs, per-final closure fingerprint, dependency-order builds, and closure rollback. No existing final's behavior changes.

#### Scenario: aiwb track converges
- **WHEN** `scripts/refresh-images check` runs with all aiwb inputs converged
- **THEN** it reports images up to date and changes nothing

#### Scenario: aiwb stale rebuilds independently
- **WHEN** only aiwb inputs go stale
- **THEN** apply rebuilds and revalidates aiwb alone, preserving all other finals' tags

/*
Phase 303 — Governance Fixture Corpus
Canonical deterministic governance signal fixtures
Test-only data
No runtime usage
*/

import { GovernanceSignal } from "./governance_advisory_presenter"

export const GOVERNANCE_FIXTURE_EMPTY: GovernanceSignal[] = []

export const GOVERNANCE_FIXTURE_HEALTHY: GovernanceSignal[] = [
  { id: "info-1", severity: "info" }
]

export const GOVERNANCE_FIXTURE_WARNING: GovernanceSignal[] = [
  { id: "warn-1", severity: "warning" }
]

export const GOVERNANCE_FIXTURE_RISK: GovernanceSignal[] = [
  { id: "risk-1", severity: "risk" }
]

export const GOVERNANCE_FIXTURE_CRITICAL: GovernanceSignal[] = [
  { id: "crit-1", severity: "critical" }
]

export const GOVERNANCE_FIXTURE_MIXED: GovernanceSignal[] = [

  { id: "crit-1", severity: "critical" },
  { id: "risk-1", severity: "risk" },
  { id: "warn-1", severity: "warning" },
  { id: "info-1", severity: "info" }

]

export const GOVERNANCE_FIXTURE_DUPLICATES: GovernanceSignal[] = [

  { id: "warn-1", severity: "warning" },
  { id: "warn-2", severity: "warning" },
  { id: "warn-3", severity: "warning" }

]


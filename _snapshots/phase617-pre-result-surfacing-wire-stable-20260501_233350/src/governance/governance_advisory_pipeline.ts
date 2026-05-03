/*
Phase 300 — Governance Advisory Composition Pipeline
End-to-end deterministic advisory assembly
Pure cognition orchestration only
NO routing
NO enforcement
NO mutation
*/

import {
  GovernanceSignal,
  buildGovernancePresentation
} from "./governance_advisory_presenter"

import {
  buildGovernanceDigest
} from "./governance_advisory_digest"

import {
  buildGovernanceOperatorView,
  GovernanceOperatorView
} from "./governance_advisory_operator_view"

import {
  GovernancePresentation
} from "./governance_advisory_presenter"

import {
  GovernanceDigest
} from "./governance_advisory_digest"

export type GovernanceAdvisoryPipelineResult = {
  presentation: GovernancePresentation
  digest: GovernanceDigest
  operator_view: GovernanceOperatorView
}

export function runGovernanceAdvisoryPipeline(
  signals: GovernanceSignal[]
): GovernanceAdvisoryPipelineResult {

  const presentation =
    buildGovernancePresentation(signals)

  const digest =
    buildGovernanceDigest(presentation)

  const operator_view =
    buildGovernanceOperatorView(digest)

  return {
    presentation,
    digest,
    operator_view
  }

}

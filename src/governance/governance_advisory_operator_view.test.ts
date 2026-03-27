/*
Phase 299 — Governance Operator View Tests
Deterministic cognition validation
*/

import {
  buildGovernancePresentation
} from "./governance_advisory_presenter"

import {
  buildGovernanceDigest
} from "./governance_advisory_digest"

import {
  buildGovernanceOperatorView
} from "./governance_advisory_operator_view"

function signal(id:string,severity:string){
  return { id, severity }
}

describe("governance operator advisory view", () => {

  it("flags critical state", () => {

    const digest =
      buildGovernanceDigest(
        buildGovernancePresentation([
          signal("1","critical")
        ])
      )

    const view =
      buildGovernanceOperatorView(digest)

    expect(view.status)
      .toBe("critical")

  })

  it("flags attention state", () => {

    const digest =
      buildGovernanceDigest(
        buildGovernancePresentation([
          signal("1","warning")
        ])
      )

    const view =
      buildGovernanceOperatorView(digest)

    expect(view.status)
      .toBe("attention")

  })

  it("flags healthy state", () => {

    const digest =
      buildGovernanceDigest(
        buildGovernancePresentation([])
      )

    const view =
      buildGovernanceOperatorView(digest)

    expect(view.status)
      .toBe("healthy")

  })

})

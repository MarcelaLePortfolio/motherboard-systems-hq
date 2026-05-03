/*
Phase 297 — Governance Advisory Digest Tests
Deterministic cognition validation
*/

import {
  buildGovernancePresentation
} from "./governance_advisory_presenter"

import {
  buildGovernanceDigest
} from "./governance_advisory_digest"

function signal(id:string,severity:string){
  return { id, severity }
}

describe("governance advisory digest", () => {

  it("detects highest severity", () => {

    const presentation =
      buildGovernancePresentation([

        signal("1","warning"),
        signal("2","risk"),
        signal("3","critical")

      ])

    const digest =
      buildGovernanceDigest(presentation)

    expect(digest.highest_severity)
      .toBe("critical")

  })

  it("returns null when empty", () => {

    const presentation =
      buildGovernancePresentation([])

    const digest =
      buildGovernanceDigest(presentation)

    expect(digest.highest_severity)
      .toBe(null)

  })

})

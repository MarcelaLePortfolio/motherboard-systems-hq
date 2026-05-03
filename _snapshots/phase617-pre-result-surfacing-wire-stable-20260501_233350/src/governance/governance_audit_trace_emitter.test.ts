import { emitGovernanceAuditTrace } from "./governance_audit_trace_emitter"
import { GOVERNANCE_FIXTURE_WARNING } from "./governance_fixture_corpus"

describe("Governance audit trace emitter", () => {

  it("emits a trace with expected structure", () => {

    const result =
      emitGovernanceAuditTrace(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.governance_audit_trace)
      .toBeDefined()

    expect(result.governance_audit_trace.signal_count)
      .toBeGreaterThanOrEqual(0)

    expect(result.governance_audit_trace.operator_authority)
      .toBe("preserved")

  })

})

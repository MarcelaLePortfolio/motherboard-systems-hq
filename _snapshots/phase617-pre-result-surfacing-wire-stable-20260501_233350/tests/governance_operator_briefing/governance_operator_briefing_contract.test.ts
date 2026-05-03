import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES,
  getGovernanceOperatorBriefingLayerGuarantees,
} from "../../src/governance_operator_briefing/governance_operator_briefing_contract";

describe("governance_operator_briefing_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter manifest source semantics",
      "cannot alter briefing ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorBriefingLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES)).toBe(true);
  });
});

import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES,
  getGovernanceOperatorLogbookLayerGuarantees,
} from "../../src/governance_operator_logbook/governance_operator_logbook_contract";

describe("governance_operator_logbook_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter record source semantics",
      "cannot alter logbook ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorLogbookLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES)).toBe(true);
  });
});

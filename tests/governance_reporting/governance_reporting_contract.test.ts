import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_REPORTING_LAYER_GUARANTEES,
  getGovernanceReportingLayerGuarantees,
} from "../../src/governance_reporting/governance_reporting_contract";

describe("governance_reporting_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_REPORTING_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceReportingLayerGuarantees()).toBe(
      GOVERNANCE_REPORTING_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_REPORTING_LAYER_GUARANTEES)).toBe(true);
  });
});

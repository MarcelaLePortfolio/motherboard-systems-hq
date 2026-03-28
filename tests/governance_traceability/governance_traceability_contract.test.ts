import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES,
  getGovernanceTraceabilityLayerGuarantees,
} from "../../src/governance_traceability/governance_traceability_contract";

describe("governance_traceability_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceTraceabilityLayerGuarantees()).toBe(
      GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES)).toBe(true);
  });
});

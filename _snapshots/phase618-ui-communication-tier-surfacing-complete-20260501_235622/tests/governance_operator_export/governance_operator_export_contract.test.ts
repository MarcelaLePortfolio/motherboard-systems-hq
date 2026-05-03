import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES,
  getGovernanceOperatorExportLayerGuarantees,
} from "../../src/governance_operator_export/governance_operator_export_contract";

describe("governance_operator_export_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter bundle source semantics",
      "cannot alter export ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorExportLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES)).toBe(true);
  });
});

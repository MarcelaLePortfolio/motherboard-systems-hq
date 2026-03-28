import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES,
  getGovernanceOperatorSnapshotLayerGuarantees,
} from "../../src/governance_operator_snapshot/governance_operator_snapshot_contract";

describe("governance_operator_snapshot_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter session source semantics",
      "cannot alter snapshot ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorSnapshotLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES)).toBe(true);
  });
});

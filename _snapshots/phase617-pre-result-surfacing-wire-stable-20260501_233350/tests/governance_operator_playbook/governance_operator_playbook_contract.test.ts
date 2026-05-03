import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES,
  getGovernanceOperatorPlaybookLayerGuarantees,
} from "../../src/governance_operator_playbook/governance_operator_playbook_contract";

describe("governance_operator_playbook_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter manual source semantics",
      "cannot alter playbook ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorPlaybookLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES)).toBe(true);
  });
});

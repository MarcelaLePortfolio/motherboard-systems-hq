import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES,
  getGovernanceOperatorConsoleLayerGuarantees,
} from "../../src/governance_operator_console/governance_operator_console_contract";

describe("governance_operator_console_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter briefing source semantics",
      "cannot alter console ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorConsoleLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES)).toBe(true);
  });
});

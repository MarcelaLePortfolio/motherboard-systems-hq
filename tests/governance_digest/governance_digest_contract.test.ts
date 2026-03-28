import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_DIGEST_LAYER_GUARANTEES,
  getGovernanceDigestLayerGuarantees,
} from "../../src/governance_digest/governance_digest_contract";

describe("governance_digest_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_DIGEST_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter reporting source semantics",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceDigestLayerGuarantees()).toBe(
      GOVERNANCE_DIGEST_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_DIGEST_LAYER_GUARANTEES)).toBe(true);
  });
});

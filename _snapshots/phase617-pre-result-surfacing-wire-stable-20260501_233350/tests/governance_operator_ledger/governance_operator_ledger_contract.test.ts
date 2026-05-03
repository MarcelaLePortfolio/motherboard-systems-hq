import { describe, expect, it } from "vitest";
import {
GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES,
getGovernanceOperatorLedgerLayerGuarantees
} from "../../src/governance_operator_ledger/governance_operator_ledger_contract";

describe("governance_operator_ledger_contract", () => {

it("exposes guarantees", () => {
expect(GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES).toEqual([
"cannot mutate decision result",
"cannot affect routing",
"cannot affect invariant evaluation",
"cannot alter explanation",
"cannot alter audit artifacts",
"cannot alter stage history",
"cannot alter atlas source semantics",
"cannot alter ledger ordering determinism",
]);
});

it("returns same reference", () => {
expect(getGovernanceOperatorLedgerLayerGuarantees())
.toBe(GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES);
});

it("is frozen", () => {
expect(Object.isFrozen(GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES))
.toBe(true);
});

});

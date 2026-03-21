/*
────────────────────────────────
PHASE 97 DETERMINISTIC PROOF
Structural verification only.
No runtime integration.
────────────────────────────────
*/

import { GOVERNANCE_MAPPINGS } from "./mappings";
import { verifyGovernanceModel } from "./verification";

export function phase97GovernanceProof(): boolean {
  const report = verifyGovernanceModel(GOVERNANCE_MAPPINGS);

  if (!report.ok) {
    throw new Error(
      "Phase97 governance invariant failure: " +
      report.results
        .filter(r => !r.ok)
        .map(r => r.invariant)
        .join(", ")
    );
  }

  return true;
}

/*
Deterministic invocation guard.
Must remain side-effect free.
*/
phase97GovernanceProof();

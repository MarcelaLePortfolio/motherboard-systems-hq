import { verifyOperationalConfidenceDeterminism } from "./confidenceInvariant";

export function runOperationalConfidenceProof(): void {
  verifyOperationalConfidenceDeterminism();
}

runOperationalConfidenceProof();

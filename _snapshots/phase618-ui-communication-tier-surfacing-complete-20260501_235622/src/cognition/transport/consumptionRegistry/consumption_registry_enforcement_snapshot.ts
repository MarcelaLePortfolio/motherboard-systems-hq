import {
  runConsumptionRegistryEnforcementProof,
  type ConsumptionRegistryEnforcementProofResult,
} from "./consumption_registry_enforcement_proof";

export interface ConsumptionRegistryEnforcementSnapshot {
  ok: boolean;
  generatedAt: string;
  lines: ReadonlyArray<string>;
}

function sortLines(lines: ReadonlyArray<string>): string[] {
  return [...lines].sort((left, right) => left.localeCompare(right));
}

function toSnapshotLines(
  proofResult: ConsumptionRegistryEnforcementProofResult,
): string[] {
  return sortLines([
    `ok=${proofResult.ok}`,
    ...proofResult.lines,
  ]);
}

export function createConsumptionRegistryEnforcementSnapshot(
  generatedAt = "deterministic-proof",
): ConsumptionRegistryEnforcementSnapshot {
  const proofResult = runConsumptionRegistryEnforcementProof();

  return {
    ok: proofResult.ok,
    generatedAt,
    lines: toSnapshotLines(proofResult),
  };
}

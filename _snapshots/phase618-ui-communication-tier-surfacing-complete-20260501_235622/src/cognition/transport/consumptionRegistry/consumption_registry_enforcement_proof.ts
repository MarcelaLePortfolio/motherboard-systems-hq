import {
  createConsumptionRegistryEnforcementFixtureProof,
  type ConsumptionRegistryEnforcementFixtureProof,
} from "./consumption_registry_enforcement_fixture";

export interface ConsumptionRegistryEnforcementProofResult {
  ok: boolean;
  proof: ConsumptionRegistryEnforcementFixtureProof;
  lines: ReadonlyArray<string>;
}

function sortLines(lines: ReadonlyArray<string>): string[] {
  return [...lines].sort((left, right) => left.localeCompare(right));
}

export function runConsumptionRegistryEnforcementProof(): ConsumptionRegistryEnforcementProofResult {
  const proof = createConsumptionRegistryEnforcementFixtureProof();

  const ok =
    proof.valid.ok === true &&
    proof.valid.errorCount === 0 &&
    proof.validReport.summary.ok === true &&
    proof.invalid.ok === false &&
    proof.invalid.errorCount > 0 &&
    proof.invalidReport.summary.ok === false &&
    proof.invalidReport.summary.missingConsumerCount > 0 &&
    proof.invalidReport.summary.duplicateOwnershipCount > 0;

  const lines = sortLines([
    `ok=${ok}`,
    `valid.ok=${proof.valid.ok}`,
    `valid.errorCount=${proof.valid.errorCount}`,
    `valid.summary.ok=${proof.validReport.summary.ok}`,
    `invalid.ok=${proof.invalid.ok}`,
    `invalid.errorCount=${proof.invalid.errorCount}`,
    `invalid.summary.ok=${proof.invalidReport.summary.ok}`,
    `invalid.summary.missingConsumerCount=${proof.invalidReport.summary.missingConsumerCount}`,
    `invalid.summary.duplicateOwnershipCount=${proof.invalidReport.summary.duplicateOwnershipCount}`,
  ]);

  return {
    ok,
    proof,
    lines,
  };
}

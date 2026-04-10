import type {
  GovernanceExecutionBridgeContract,
  GovernanceEvaluationEnvelope,
  NormalizedTaskEnvelope,
  PreparationEnvelope,
} from "../governanceExecutionBridgeContract";

import { buildBridgeContract } from "../adapters/governanceExecutionBridgeAdapter";
import {
  bridgeAssemblyGovernanceFixture,
  bridgeAssemblyPreparationFixture,
  bridgeAssemblyTaskFixture,
} from "../__fixtures__/governanceExecutionBridgeAssembly.fixture";

/**
 * Phase 466.5 — compile-only structural proof
 *
 * This file must remain:
 * - type-only / compile-only
 * - side-effect free
 * - runtime-independent
 */

const task: NormalizedTaskEnvelope = bridgeAssemblyTaskFixture;
const governance: GovernanceEvaluationEnvelope = bridgeAssemblyGovernanceFixture;
const preparation: PreparationEnvelope = bridgeAssemblyPreparationFixture;

export const governanceExecutionBridgeTypeproof: GovernanceExecutionBridgeContract =
  buildBridgeContract({
    task,
    governance,
    preparation,
  });

export function assertBridgeContractShape(
  input: GovernanceExecutionBridgeContract,
): GovernanceExecutionBridgeContract {
  return input;
}

export const governanceExecutionBridgeTypeproofRoundTrip =
  assertBridgeContractShape(governanceExecutionBridgeTypeproof);

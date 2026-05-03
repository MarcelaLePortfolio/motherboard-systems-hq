/**
 * Phase 468.0 — Demo Path Structural Stitching Proof
 *
 * Goal:
 * Create a single, deterministic, non-runtime path:
 *
 * intake → governance → execution proof → operator surface
 *
 * No execution.
 * No runtime wiring.
 * No authority mutation.
 */

import type { GovernanceExecutionBridgeContract } from "../governanceExecutionBridgeContract";
import { buildBridgeContract } from "../adapters/governanceExecutionBridgeAdapter";

import { executionProofAllowedFixture } from "../execution/__fixtures__/governedExecutionProof.fixture";
import { executeGovernedProof } from "../execution/governedExecutionProof";

import { buildGovernedExecutionProofReport } from "../reporting/governedExecutionProofReport";
import { buildOperatorConsumableExecutionProofSurface } from "../reporting/operatorConsumableExecutionProofSurface";

export interface DemoPathProofResult {
  bridge: GovernanceExecutionBridgeContract;
  execution: ReturnType<typeof executeGovernedProof>;
  report: ReturnType<typeof buildGovernedExecutionProofReport>;
  surface: ReturnType<typeof buildOperatorConsumableExecutionProofSurface>;
}

export function runDemoPathProof(): DemoPathProofResult {
  // Step 1 — Bridge contract assembly (intake + governance + preparation)
  const bridge = buildBridgeContract({
    task: executionProofAllowedFixture.intake.task,
    governance: executionProofAllowedFixture.governance,
    preparation: executionProofAllowedFixture.preparation,
  });

  // Step 2 — Governed execution proof (still non-runtime)
  const execution = executeGovernedProof({
    governance: bridge.governance,
    approval: { approved: true },
    preparation: bridge.preparation,
  });

  // Step 3 — Reporting surface
  const report = buildGovernedExecutionProofReport(execution);

  // Step 4 — Operator-consumable surface
  const surface = buildOperatorConsumableExecutionProofSurface(report);

  return {
    bridge,
    execution,
    report,
    surface,
  };
}

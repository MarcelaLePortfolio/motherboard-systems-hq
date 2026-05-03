import { strict as assert } from "node:assert";
import {
  buildSituationSummary,
  getSystemSituationSummary,
  type GovernanceAwarenessSurface,
} from "./index";

const VERIFIED_GOVERNANCE: GovernanceAwarenessSurface = {
  structure: {
    capabilityRegistryVisible: true,
    workerAuthorityModelVisible: true,
    permissionAuthorityModelVisible: true,
  },
  signals: {
    governanceAwarenessSignals: [
      {
        name: "capability_registry_visible",
        active: true,
        summary: "capability registry visible",
      },
    ],
  },
  authorityBoundaries: {
    workerAuthorityBoundary: {
      visible: true,
      summary: "worker boundary visible",
    },
    permissionAuthorityBoundary: {
      visible: true,
      summary: "permission boundary visible",
    },
  },
  verification: {
    isVerified: true,
    lastVerifiedAt: "2026-03-21T00:00:00.000Z",
    invariantTotal: 4,
    invariantFailures: 0,
  },
};

const ATTENTION_GOVERNANCE: GovernanceAwarenessSurface = {
  structure: {
    capabilityRegistryVisible: true,
    workerAuthorityModelVisible: true,
    permissionAuthorityModelVisible: false,
  },
  signals: {
    governanceAwarenessSignals: [
      {
        name: "permission_boundary_attention",
        active: false,
        summary: "permission boundary not fully visible",
      },
    ],
  },
  authorityBoundaries: {
    workerAuthorityBoundary: {
      visible: true,
      summary: "worker boundary visible",
    },
    permissionAuthorityBoundary: {
      visible: false,
      summary: "permission boundary requires review",
    },
  },
  verification: {
    isVerified: true,
    lastVerifiedAt: "2026-03-21T00:00:00.000Z",
    invariantTotal: 4,
    invariantFailures: 1,
  },
};

export type GovernanceCognitionSmokeResult = {
  ok: true;
  verifiedState: string;
  attentionState: string;
  renderedGovernanceLine: string;
};

export function runGovernanceCognitionSmoke(): GovernanceCognitionSmokeResult {
  const verifiedSummary = buildSituationSummary({
    stability: "stable",
    executionRisk: "none",
    cognition: "consistent",
    signalCoherence: "coherent",
    operatorAttention: "none",
    governanceAwareness: VERIFIED_GOVERNANCE,
  });

  const attentionSummary = buildSituationSummary({
    governanceAwareness: ATTENTION_GOVERNANCE,
  });

  const rendered = getSystemSituationSummary({
    governanceAwareness: VERIFIED_GOVERNANCE,
  });

  assert.equal(verifiedSummary.governanceCognitionState, "verified");
  assert.equal(attentionSummary.governanceCognitionState, "attention");
  assert.equal(
    verifiedSummary.summaryLines.includes("GOVERNANCE CONDITION VERIFIED"),
    true
  );
  assert.equal(
    rendered.includes("GOVERNANCE CONDITION VERIFIED"),
    true
  );

  return {
    ok: true,
    verifiedState: verifiedSummary.governanceCognitionState,
    attentionState: attentionSummary.governanceCognitionState,
    renderedGovernanceLine: "GOVERNANCE CONDITION VERIFIED",
  };
}

const isDirectExecution =
  typeof process !== "undefined" &&
  Array.isArray(process.argv) &&
  typeof process.argv[1] === "string" &&
  process.argv[1].includes("governanceCognition.smoke.ts");

if (isDirectExecution) {
  const result = runGovernanceCognitionSmoke();
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

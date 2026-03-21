import { strict as assert } from "node:assert";
import {
  buildGovernanceAwarenessSignals,
  isGovernanceAwarenessSurface,
  sanitizeGovernanceAwarenessSurface,
  type GovernanceAwarenessSurface,
} from "./index";

const VALID_GOVERNANCE_AWARENESS_SURFACE: GovernanceAwarenessSurface = {
  structure: {
    capabilityRegistryVisible: true,
    workerAuthorityModelVisible: true,
    permissionAuthorityModelVisible: true,
  },
  signals: {
    governanceAwarenessSignals: [
      {
        name: "governance_registry_visible",
        active: true,
        summary: "governance registry is visible to cognition awareness surfaces",
      },
      {
        name: "authority_boundaries_visible",
        active: true,
        summary: "worker and permission boundaries are structurally visible",
      },
    ],
  },
  authorityBoundaries: {
    workerAuthorityBoundary: {
      visible: true,
      summary: "worker authority boundary exposed as awareness-safe summary",
    },
    permissionAuthorityBoundary: {
      visible: true,
      summary: "permission authority boundary exposed as awareness-safe summary",
    },
  },
  verification: {
    isVerified: true,
    lastVerifiedAt: "2026-03-21T00:00:00.000Z",
    invariantTotal: 4,
    invariantFailures: 0,
  },
};

const INVALID_GOVERNANCE_AWARENESS_SURFACE: unknown = {
  structure: {
    capabilityRegistryVisible: true,
    workerAuthorityModelVisible: "yes",
    permissionAuthorityModelVisible: true,
  },
  signals: {
    governanceAwarenessSignals: [
      {
        name: "governance_registry_visible",
        active: true,
        summary: "invalid payload should fail because structure is malformed",
      },
    ],
  },
  authorityBoundaries: {
    workerAuthorityBoundary: {
      visible: true,
      summary: "ok",
    },
    permissionAuthorityBoundary: {
      visible: true,
      summary: "ok",
    },
  },
  verification: {
    isVerified: true,
    lastVerifiedAt: "2026-03-21T00:00:00.000Z",
    invariantTotal: 4,
    invariantFailures: 0,
  },
};

export type GovernanceAwarenessGuardsSmokeResult = {
  ok: true;
  validAccepted: true;
  invalidRejected: true;
  derivedSignalCount: number;
  derivedSignalNames: string[];
};

export function runGovernanceAwarenessGuardsSmoke(): GovernanceAwarenessGuardsSmokeResult {
  assert.equal(
    isGovernanceAwarenessSurface(VALID_GOVERNANCE_AWARENESS_SURFACE),
    true
  );

  assert.equal(
    isGovernanceAwarenessSurface(INVALID_GOVERNANCE_AWARENESS_SURFACE),
    false
  );

  assert.deepEqual(
    sanitizeGovernanceAwarenessSurface(VALID_GOVERNANCE_AWARENESS_SURFACE),
    VALID_GOVERNANCE_AWARENESS_SURFACE
  );

  assert.equal(
    sanitizeGovernanceAwarenessSurface(
      INVALID_GOVERNANCE_AWARENESS_SURFACE as GovernanceAwarenessSurface
    ),
    undefined
  );

  const derivedSignals = buildGovernanceAwarenessSignals(
    VALID_GOVERNANCE_AWARENESS_SURFACE
  );

  assert.equal(derivedSignals.governanceAwarenessSignals.length, 4);
  assert.deepEqual(
    derivedSignals.governanceAwarenessSignals.map((signal) => signal.name),
    [
      "capability_registry_visible",
      "worker_authority_boundary_visible",
      "permission_authority_boundary_visible",
      "governance_verification_healthy",
    ]
  );
  assert.equal(derivedSignals.governanceAwarenessSignals.every((signal) => signal.active), true);

  return {
    ok: true,
    validAccepted: true,
    invalidRejected: true,
    derivedSignalCount: derivedSignals.governanceAwarenessSignals.length,
    derivedSignalNames: derivedSignals.governanceAwarenessSignals.map(
      (signal) => signal.name
    ),
  };
}

const isDirectExecution =
  typeof process !== "undefined" &&
  Array.isArray(process.argv) &&
  typeof process.argv[1] === "string" &&
  process.argv[1].includes("governanceAwarenessGuards.smoke.ts");

if (isDirectExecution) {
  const result = runGovernanceAwarenessGuardsSmoke();
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

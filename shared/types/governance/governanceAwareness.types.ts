export interface GovernanceAwarenessStructure {
  readonly capabilityRegistryVisible: boolean;
  readonly workerAuthorityModelVisible: boolean;
  readonly permissionAuthorityModelVisible: boolean;
}

export interface GovernanceAwarenessSignal {
  readonly name: string;
  readonly active: boolean;
  readonly summary: string;
}

export interface GovernanceAuthorityBoundaryAwareness {
  readonly workerAuthorityBoundary: {
    readonly visible: boolean;
    readonly summary: string;
  };
  readonly permissionAuthorityBoundary: {
    readonly visible: boolean;
    readonly summary: string;
  };
}

export interface GovernanceVerificationSummary {
  readonly isVerified: boolean;
  readonly lastVerifiedAt: string;
  readonly invariantTotal: number;
  readonly invariantFailures: number;
}

export interface GovernanceAwarenessSignals {
  readonly governanceAwarenessSignals: readonly GovernanceAwarenessSignal[];
}

export interface GovernanceAwarenessSurface {
  readonly structure: GovernanceAwarenessStructure;
  readonly signals: GovernanceAwarenessSignals;
  readonly authorityBoundaries: GovernanceAuthorityBoundaryAwareness;
  readonly verification: GovernanceVerificationSummary;
}

export function buildGovernanceAwarenessSignals(
  awareness: GovernanceAwarenessSurface
): GovernanceAwarenessSignals {
  return {
    governanceAwarenessSignals: [
      {
        name: "capability_registry_visible",
        active: awareness.structure.capabilityRegistryVisible,
        summary: awareness.structure.capabilityRegistryVisible
          ? "capability registry visible to governance awareness surface"
          : "capability registry not visible to governance awareness surface",
      },
      {
        name: "worker_authority_boundary_visible",
        active: awareness.authorityBoundaries.workerAuthorityBoundary.visible,
        summary: awareness.authorityBoundaries.workerAuthorityBoundary.summary,
      },
      {
        name: "permission_authority_boundary_visible",
        active: awareness.authorityBoundaries.permissionAuthorityBoundary.visible,
        summary: awareness.authorityBoundaries.permissionAuthorityBoundary.summary,
      },
      {
        name: "governance_verification_healthy",
        active:
          awareness.verification.isVerified &&
          awareness.verification.invariantFailures === 0,
        summary: awareness.verification.isVerified
          ? "governance verification passed without invariant failures"
          : "governance verification not currently confirmed",
      },
    ],
  };
}

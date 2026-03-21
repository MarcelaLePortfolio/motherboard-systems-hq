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

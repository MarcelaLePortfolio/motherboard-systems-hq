declare global {
  interface CapabilityMetadata {
    execution_boundaries?: unknown;
    authority_scope?: unknown;
  }

  interface OperatorSignals {
    healthAnomaly?: boolean;
  }
}

export {};

/*
PHASE 114 — COGNITION TRANSPORT DIAGNOSTICS
Deterministic read-only diagnostics integration
*/

import { getCognitionTransportHealth } from "./cognitionTransport.health";
import { getCognitionTransportSnapshot } from "./cognitionTransport.snapshot";
import { transportRegistryIsConsistent } from "./cognitionTransport.invariants";
import { CognitionTransportDiagnostics } from "./CognitionTransportDiagnostics.types";
import { assertTransportReplaySafety } from "./transportReplaySafety.assert";

export function buildCognitionTransportDiagnostics(): CognitionTransportDiagnostics {
  const health = getCognitionTransportHealth();
  const snapshot = getCognitionTransportSnapshot();
  const invariantHealthy = transportRegistryIsConsistent();
  const replaySafe = assertTransportReplaySafety(snapshot);

  return {
    registryHealthy: health.registryConsistent,
    verificationHealthy: invariantHealthy,
    policyGateHealthy: health.healthy,
    invariantHealthy,
    replaySafe,
    lastVerificationTs: snapshot.timestamp,
    failureCount: 0,
    notes: replaySafe ? [] : ["transport snapshot not replay safe"]
  };
}

/*
Diagnostics rules:

Read-only only.
No runtime mutation.
Derived from existing transport health, snapshot, and invariant surfaces.
*/

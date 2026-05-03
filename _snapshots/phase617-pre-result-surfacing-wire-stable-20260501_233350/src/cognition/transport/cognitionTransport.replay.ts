/*
PHASE 114 — COGNITION TRANSPORT REPLAY SAFETY
Deterministic replay-oriented assertion surface (read-only)
*/

import { getCognitionTransportSnapshot } from "./cognitionTransport.snapshot";
import { transportRegistryIsConsistent } from "./cognitionTransport.invariants";
import { assertTransportReplaySafety } from "./transportReplaySafety.assert";

export interface CognitionTransportReplayReport {
  replaySafe: boolean;
  registryConsistent: boolean;
  snapshotTimestamp: number;
  deterministic: true;
  notes: string[];
}

export function getCognitionTransportReplayReport(): CognitionTransportReplayReport {
  const snapshot = getCognitionTransportSnapshot();
  const replaySafe = assertTransportReplaySafety(snapshot);
  const registryConsistent = transportRegistryIsConsistent();

  return {
    replaySafe,
    registryConsistent,
    snapshotTimestamp: snapshot.timestamp,
    deterministic: true,
    notes:
      replaySafe && registryConsistent
        ? []
        : [
            ...(replaySafe ? [] : ["transport snapshot not replay safe"]),
            ...(registryConsistent ? [] : ["transport registry inconsistent"])
          ]
  };
}

/*
Replay rules:

Read-only only.
No runtime mutation.
No execution coupling.
Deterministic report structure only.
*/

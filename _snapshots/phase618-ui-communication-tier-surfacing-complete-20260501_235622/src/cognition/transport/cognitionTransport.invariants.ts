/*
PHASE 113 — COGNITION TRANSPORT INVARIANTS
Deterministic invariant definitions (no runtime mutation)
*/

import { cognitionTransportRegistry } from "./cognitionTransport.registry";

export function transportRegistryIsConsistent(): boolean {

  for (const link of Object.values(cognitionTransportRegistry.links)) {

    if (!(link.channelId in cognitionTransportRegistry.channels)) {
      return false;
    }

  }

  for (const span of Object.values(cognitionTransportRegistry.spans)) {

    if (!(span.bridgeId in cognitionTransportRegistry.bridges)) {
      return false;
    }

  }

  return true;

}

/*
Invariant rules:

Links must reference valid channels.
Spans must reference valid bridges.
Registry must remain internally consistent.
Pure checks only.
*/

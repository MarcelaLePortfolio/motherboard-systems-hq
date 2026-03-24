/*
PHASE 113 — COGNITION TRANSPORT SNAPSHOT
Deterministic observability surface (read-only)
*/

import { cognitionTransportRegistry } from "./cognitionTransport.registry";
import { CognitionTransportSnapshot } from "./cognitionTransport.types";

export function getCognitionTransportSnapshot(): CognitionTransportSnapshot {

  return {

    channelCount: Object.keys(cognitionTransportRegistry.channels).length,

    linkCount: Object.keys(cognitionTransportRegistry.links).length,

    bridgeCount: Object.keys(cognitionTransportRegistry.bridges).length,

    spanCount: Object.keys(cognitionTransportRegistry.spans).length,

    timestamp: Date.now()

  };

}

/*
Snapshot rules:

Read-only inspection only.
No mutation allowed.
Deterministic structure.
*/

/*
PHASE 113 — COGNITION TRANSPORT HEALTH SURFACE
Deterministic health evaluation (read-only)
*/

import { cognitionTransportRegistry } from "./cognitionTransport.registry";
import { transportRegistryIsConsistent } from "./cognitionTransport.invariants";

export interface CognitionTransportHealth {

  registryConsistent: boolean;

  channelCount: number;

  linkCount: number;

  bridgeCount: number;

  spanCount: number;

  healthy: boolean;

}

export function getCognitionTransportHealth(): CognitionTransportHealth {

  const registryConsistent = transportRegistryIsConsistent();

  const channelCount = Object.keys(cognitionTransportRegistry.channels).length;

  const linkCount = Object.keys(cognitionTransportRegistry.links).length;

  const bridgeCount = Object.keys(cognitionTransportRegistry.bridges).length;

  const spanCount = Object.keys(cognitionTransportRegistry.spans).length;

  const healthy =
    registryConsistent &&
    channelCount >= 0 &&
    linkCount >= 0 &&
    bridgeCount >= 0 &&
    spanCount >= 0;

  return {

    registryConsistent,

    channelCount,

    linkCount,

    bridgeCount,

    spanCount,

    healthy

  };

}

/*
Health rules:

Read-only inspection only.
No mutation allowed.
Deterministic evaluation.
*/

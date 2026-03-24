/*
PHASE 113 — COGNITION TRANSPORT VERIFICATION
Deterministic verification layer (no runtime mutation)
*/

import { cognitionTransportRegistry } from "./cognitionTransport.registry";

export function verifyChannelExists(channelId: string): boolean {
  return channelId in cognitionTransportRegistry.channels;
}

export function verifyLinkExists(linkId: string): boolean {
  return linkId in cognitionTransportRegistry.links;
}

export function verifyBridgeExists(bridgeId: string): boolean {
  return bridgeId in cognitionTransportRegistry.bridges;
}

export function verifySpanExists(spanId: string): boolean {
  return spanId in cognitionTransportRegistry.spans;
}

/*
Verification rules:

Reject undefined transport.
No mutation permitted.
Pure deterministic checks only.
*/

/*
PHASE 113 — COGNITION TRANSPORT VALIDATION
Deterministic transport validation entrypoint (no runtime mutation)
*/

import { transportRegistryIsConsistent } from "./cognitionTransport.invariants";
import {
  transportFailure,
  transportSuccess,
  TransportResult
} from "./cognitionTransport.failure";
import {
  verifyBridgeExists,
  verifyChannelExists,
  verifyLinkExists,
  verifySpanExists
} from "./cognitionTransport.verify";

export interface CognitionTransportValidationInput {
  channelId: string;
  linkId: string;
  bridgeId: string;
  spanId: string;
}

export function validateCognitionTransport(
  input: CognitionTransportValidationInput
): TransportResult {
  if (!verifyChannelExists(input.channelId)) {
    return transportFailure("CHANNEL_MISSING");
  }

  if (!verifyLinkExists(input.linkId)) {
    return transportFailure("LINK_MISSING");
  }

  if (!verifyBridgeExists(input.bridgeId)) {
    return transportFailure("BRIDGE_MISSING");
  }

  if (!verifySpanExists(input.spanId)) {
    return transportFailure("SPAN_MISSING");
  }

  if (!transportRegistryIsConsistent()) {
    return transportFailure("REGISTRY_INCONSISTENT");
  }

  return transportSuccess();
}

/*
Validation rules:

Reject missing transport components.
Reject inconsistent registry state.
Return deterministic result only.
No mutation permitted.
*/

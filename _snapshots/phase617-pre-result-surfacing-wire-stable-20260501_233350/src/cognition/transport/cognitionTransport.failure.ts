/*
PHASE 113 — COGNITION TRANSPORT FAILURE MODEL
Deterministic rejection + failure signaling (no runtime mutation)
*/

export type TransportFailureReason =
  | "CHANNEL_MISSING"
  | "LINK_MISSING"
  | "BRIDGE_MISSING"
  | "SPAN_MISSING"
  | "REGISTRY_INCONSISTENT";

export interface TransportFailure {
  ok: false;
  reason: TransportFailureReason;
}

export interface TransportSuccess {
  ok: true;
}

export type TransportResult =
  | TransportSuccess
  | TransportFailure;

export function transportFailure(reason: TransportFailureReason): TransportFailure {

  return {
    ok: false,
    reason
  };

}

export function transportSuccess(): TransportSuccess {

  return {
    ok: true
  };

}

/*
Failure rules:

No silent failure.
All failures must return reason.
No mutation permitted.
Deterministic responses only.
*/

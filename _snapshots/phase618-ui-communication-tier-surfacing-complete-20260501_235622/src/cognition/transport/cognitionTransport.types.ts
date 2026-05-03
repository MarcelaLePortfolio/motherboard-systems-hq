/*
PHASE 113 — COGNITION TRANSPORT HARDENING
Deterministic transport contracts (types only — no runtime mutation)
*/

export type CognitionChannelId = string;
export type CognitionLinkId = string;
export type CognitionBridgeId = string;
export type CognitionSpanId = string;

export interface CognitionChannel {
  id: CognitionChannelId;
  source: string;
  destination: string;
  active: boolean;
}

export interface CognitionLink {
  id: CognitionLinkId;
  channelId: CognitionChannelId;
  description?: string;
  active: boolean;
}

export interface CognitionBridge {
  id: CognitionBridgeId;
  fromDomain: string;
  toDomain: string;
  governanceRequired: boolean;
}

export interface CognitionSpan {
  id: CognitionSpanId;
  bridgeId: CognitionBridgeId;
  maxRange: number;
  active: boolean;
}

export interface CognitionTransportRegistry {
  channels: Record<CognitionChannelId, CognitionChannel>;
  links: Record<CognitionLinkId, CognitionLink>;
  bridges: Record<CognitionBridgeId, CognitionBridge>;
  spans: Record<CognitionSpanId, CognitionSpan>;
}

export interface CognitionTransportSnapshot {
  channelCount: number;
  linkCount: number;
  bridgeCount: number;
  spanCount: number;
  timestamp: number;
}

/*
Transport invariants:

Transport moves cognition only.
Transport cannot create cognition.
Transport cannot mutate governance.
Transport must remain deterministic.
*/

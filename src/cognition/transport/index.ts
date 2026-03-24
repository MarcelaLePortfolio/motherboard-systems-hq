/*
PHASE 114 — COGNITION TRANSPORT BARREL
Deterministic export surface for transport layer
*/

export * from "./cognitionTransport.types";
export * from "./cognitionTransport.registry";
export * from "./cognitionTransport.snapshot";
export * from "./cognitionTransport.verify";
export * from "./cognitionTransport.invariants";
export * from "./cognitionTransport.failure";
export * from "./cognitionTransport.validate";
export * from "./cognitionTransport.policy";
export * from "./cognitionTransport.health";
export * from "./cognitionTransport.diagnostics";
export * from "./CognitionTransportDiagnostics.types";
export * from "./CognitionTransportDiagnostics.builder";
export * from "./transportReplaySafety.assert";

/*
Barrel rules:

Single export surface.
No runtime behavior.
Phase 113 exports preserved.
Phase 114 diagnostics exports added without drift.
*/

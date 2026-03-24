/*
PHASE 113 — COGNITION TRANSPORT BARREL
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

/*
Barrel rules:

Single export surface.
No runtime behavior.
Types + registry + verification + invariants + failure + validation + policy + snapshot only.
*/

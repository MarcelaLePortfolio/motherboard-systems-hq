// OBSERVABILITY INTEGRATION GUARD (HARD BLOCK)

// This file exists to PREVENT unsafe integration.
// Do NOT import this file into execution paths.

// If this file is ever imported, it should immediately signal misuse.

throw new Error(
  "OBSERVABILITY GUARD TRIGGERED: Do not integrate observability into execution paths."
);

// Purpose:
// - Enforce architectural boundary
// - Prevent accidental coupling
// - Act as a safety tripwire

// Status:
// DO NOT USE — PROTECTIVE ONLY

#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

node --input-type=module <<'NODE'
import { assertActionTierInvariant } from "./server/guards/phase44_runtime_integrity_guard.mjs";

function mustThrow(fn, label) {
  let threw = false;
  try { fn(); } catch (e) { threw = true; }
  if (!threw) throw new Error(`EXPECTED_THROW_FAILED: ${label}`);
}

function mustNotThrow(fn, label) {
  try { fn(); } catch (e) { throw new Error(`UNEXPECTED_THROW: ${label}: ${e?.message ?? e}`); }
}

mustNotThrow(() => assertActionTierInvariant({ actionTier: "A", actionId: "anything" }), "tierA_ok");
mustThrow(() => assertActionTierInvariant({ actionTier: "B", actionId: "unauthorized.action" }), "tierB_blocked");
mustNotThrow(() => assertActionTierInvariant({ actionTier: "B", actionId: "system.selftest.authorized_tier_b" }), "tierB_allowlisted_ok");
mustThrow(() => assertActionTierInvariant({ actionTier: "C", actionId: "unauthorized.action" }), "tierC_blocked");

console.log("OK: Phase 44 action-tier guard smoke passed");
NODE

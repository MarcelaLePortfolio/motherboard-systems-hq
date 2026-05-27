import type { Runbook } from "./operatorRunbookTypes";

export const RUNBOOK_STABLE_CONTINUE: Runbook = {
  id: "RUNBOOK_STABLE_CONTINUE",
  title: "System Stable — Continue Development",
  risk: "SAFE",
  state: "STABLE",
  continueSafe: true,
  steps: [
    { id: "verify-diagnostics", description: "Verify diagnostics report clean" },
    { id: "verify-drift", description: "Verify drift detector clean" },
    { id: "verify-reducers", description: "Verify reducers healthy" },
    { id: "continue", description: "Continue development" }
  ]
};

export const RUNBOOK_INVESTIGATE_DRIFT: Runbook = {
  id: "RUNBOOK_INVESTIGATE_DRIFT",
  title: "Investigate Telemetry Drift",
  risk: "MEDIUM",
  state: "INVESTIGATE",
  continueSafe: false,
  steps: [
    { id: "check-drift", description: "Check drift report" },
    { id: "check-replay", description: "Check replay validation" },
    { id: "compare-state", description: "Compare reducer snapshots" },
    { id: "hold", description: "Hold changes until verified" }
  ]
};

export const RUNBOOK_RECOVERY_FIRST: Runbook = {
  id: "RUNBOOK_RECOVERY_FIRST",
  title: "Recovery First Protocol",
  risk: "HIGH",
  state: "RECOVERY",
  continueSafe: false,
  steps: [
    { id: "identify-golden", description: "Identify last golden tag" },
    { id: "restore", description: "Restore if structural issue detected" },
    { id: "verify-layout", description: "Verify layout contract" },
    { id: "reapply", description: "Reapply work cleanly" }
  ]
};

export const RUNBOOK_OBSERVE_ONLY: Runbook = {
  id: "RUNBOOK_OBSERVE_ONLY",
  title: "Observation Only",
  risk: "LOW",
  state: "OBSERVE",
  continueSafe: false,
  steps: [
    { id: "no-change", description: "No change allowed" },
    { id: "monitor", description: "Monitor telemetry" },
    { id: "rerun", description: "Re-run diagnostics later" }
  ]
};

export const RUNBOOK_CATALOG: Record<string, Runbook> = {
  RUNBOOK_STABLE_CONTINUE,
  RUNBOOK_INVESTIGATE_DRIFT,
  RUNBOOK_RECOVERY_FIRST,
  RUNBOOK_OBSERVE_ONLY
};

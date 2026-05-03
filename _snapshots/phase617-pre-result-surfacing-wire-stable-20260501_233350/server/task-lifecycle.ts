
// Phase 39: Action Tier scaffolding
const __mbActionTierAllowed = new Set(['A','B','C']);
function __mbNormalizeActionTier(tier: any): 'A'|'B'|'C' {
  const t = (tier ?? 'A');
  if (!__mbActionTierAllowed.has(String(t))) return 'A';
  return String(t) as any;
}
function __mbRequireDisclosureIfBC(tier: 'A'|'B'|'C', title: any, body: any) {
  if (tier === 'A') return;
  const t = String(title ?? '').trim();
  const b = String(body ?? '').trim();
  if (!t || !b) {
    const err: any = new Error('Tier B/C requires tier_disclosure_title and tier_disclosure_body');
    err.statusCode = 400;
    throw err;
  }
}
/**
 * Phase 24 — Step 1
 * Canonical task lifecycle guard
 */

export type TaskState = "created" | "running" | "completed" | "failed";

const ORDER: Record<TaskState, number> = {
  created: 0,
  running: 1,
  completed: 2,
  failed: 2,
};

export function isValidTransition(
  prev: TaskState | null,
  next: TaskState
): boolean {
  if (prev === null) return next === "created";
  if (prev === "completed" || prev === "failed") return false;
  return ORDER[next] >= ORDER[prev];
}

export function isTerminal(state: TaskState): boolean {
  return state === "completed" || state === "failed";
}

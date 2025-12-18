/*
 Phase 14.2 — Task contract validation + normalization
 Small + defensive, no external deps.

 Notes:
 - We preserve DB timestamps on read.
 - We normalize legacy status strings into the Phase 14 enum.
*/

export const TASK_STATUSES = new Set([
  "queued",
  "delegated",
  "running",
  "blocked",
  "complete",
  "canceled",
  "failed",
]);

export const TERMINAL_STATUSES = new Set(["complete", "canceled", "failed"]);

export function normalizeStatus(raw) {
  const s = (typeof raw === "string" ? raw : "").trim().toLowerCase();

  // legacy mappings
  if (s === "completed") return "complete";
  if (s === "started") return "running";

  // already canonical
  if (TASK_STATUSES.has(s)) return s;

  // tolerate empty/unknown -> queued
  return "queued";
}

export function normalizeTaskForRead(raw = {}) {
  const now = new Date().toISOString();

  return {
    id: raw.id != null ? String(raw.id) : null,
    title: typeof raw.title === "string" ? raw.title.trim() : "",
    agent: typeof raw.agent === "string" ? raw.agent.trim() : "",
    status: normalizeStatus(raw.status),

    notes: raw.notes ?? null,
    source: raw.source ?? null,
    trace_id: raw.trace_id ?? null,
    error: raw.error ?? null,
    meta: raw.meta ?? null,

    created_at: raw.created_at || raw.createdAt || now,
    updated_at: raw.updated_at || raw.updatedAt || now,
  };
}

export function normalizeTaskForWrite(raw = {}) {
  const now = new Date().toISOString();
  const base = normalizeTaskForRead(raw);

  return {
    ...base,
    // server controls updated_at; created_at only if missing
    created_at: base.created_at || now,
    updated_at: now,
  };
}

export function validateNewTask(task) {
  if (!task.title) throw new Error("Task title is required");
  if (!task.agent) throw new Error("Task agent is required");
  if (!TASK_STATUSES.has(task.status)) throw new Error(`Invalid status: ${task.status}`);
}

export function validateTransition(prevStatusRaw, nextStatusRaw) {
  const prevStatus = normalizeStatus(prevStatusRaw);
  const nextStatus = normalizeStatus(nextStatusRaw);

  if (prevStatus === nextStatus) return;

  if (TERMINAL_STATUSES.has(prevStatus)) {
    throw new Error(`Cannot transition from terminal status: ${prevStatus}`);
  }

  const allowed = {
    queued: ["delegated", "canceled", "failed"],
    delegated: ["running", "canceled", "failed"],
    running: ["complete", "blocked", "canceled", "failed"],
    blocked: ["running", "canceled", "failed"],
  };

  const nextAllowed = allowed[prevStatus] || [];
  if (!nextAllowed.includes(nextStatus)) {
    throw new Error(`Invalid transition: ${prevStatus} → ${nextStatus}`);
  }
}

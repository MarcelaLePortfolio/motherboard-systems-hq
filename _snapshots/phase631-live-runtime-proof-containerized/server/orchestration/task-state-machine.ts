export type TaskState =
  | "DRAFT"
  | "QUEUED"
  | "ROUTED"
  | "RUNNING"
  | "WAITING"
  | "RETRY_WAIT"
  | "SUCCEEDED"
  | "FAILED"
  | "CANCELED";

export type Task = {
  id: string;
  kind: string;
  createdAt: number;
  updatedAt: number;
  state: TaskState;
  priority: number;
  attempts: number;
  maxAttempts: number;
  dependsOn: string[];
  payload: unknown;
  lastError: string | null;
};

export type TaskEvent =
  | { type: "task.queue"; ts: number }
  | { type: "task.route"; ts: number; agent: string }
  | { type: "task.start"; ts: number }
  | { type: "task.wait"; ts: number; reason: string }
  | { type: "task.retry_wait"; ts: number; reason: string; nextAt: number }
  | { type: "task.succeed"; ts: number }
  | { type: "task.fail"; ts: number; error: string }
  | { type: "task.cancel"; ts: number; by: "operator" | "policy"; reason?: string };

export type TransitionResult =
  | { ok: true; task: Task }
  | { ok: false; error: string; task: Task };

const ALLOWED: Record<TaskState, Set<TaskState>> = {
  DRAFT: new Set(["QUEUED", "CANCELED"]),
  QUEUED: new Set(["ROUTED", "CANCELED"]),
  ROUTED: new Set(["RUNNING", "QUEUED", "CANCELED"]),
  RUNNING: new Set(["WAITING", "RETRY_WAIT", "SUCCEEDED", "FAILED", "CANCELED"]),
  WAITING: new Set(["QUEUED", "CANCELED"]),
  RETRY_WAIT: new Set(["QUEUED", "CANCELED"]),
  SUCCEEDED: new Set([]),
  FAILED: new Set([]),
  CANCELED: new Set([]),
};

export function canTransition(from: TaskState, to: TaskState): boolean {
  return ALLOWED[from].has(to);
}

export function reduceTask(task: Task, ev: TaskEvent): TransitionResult {
  const t: Task = { ...task, updatedAt: ev.ts };

  function go(next: TaskState): TransitionResult {
    if (!canTransition(t.state, next)) {
      return { ok: false, error: `disallowed transition ${t.state} -> ${next}`, task: t };
    }
    return { ok: true, task: { ...t, state: next } };
  }

  switch (ev.type) {
    case "task.queue":
      return go("QUEUED");
    case "task.route":
      return go("ROUTED");
    case "task.start":
      return go("RUNNING");
    case "task.wait":
      return go("WAITING");
    case "task.retry_wait": {
      const nextAttempts = t.attempts + 1;
      if (nextAttempts > t.maxAttempts) {
        return { ok: false, error: "maxAttempts exceeded", task: t };
      }
      return { ok: true, task: { ...t, attempts: nextAttempts, state: "RETRY_WAIT", lastError: ev.reason } };
    }
    case "task.succeed":
      return go("SUCCEEDED");
    case "task.fail": {
      const nextAttempts = t.attempts + 1;
      if (nextAttempts >= t.maxAttempts) {
        return { ok: true, task: { ...t, attempts: nextAttempts, state: "FAILED", lastError: ev.error } };
      }
      return { ok: false, error: "non-terminal fail requires policy (Phase 17.2)", task: { ...t, attempts: nextAttempts, lastError: ev.error } };
    }
    case "task.cancel":
      if (t.state === "SUCCEEDED" || t.state === "FAILED" || t.state === "CANCELED") {
        return { ok: false, error: `cannot cancel terminal state ${t.state}`, task: t };
      }
      return go("CANCELED");
    default:
      return { ok: false, error: "unknown event", task: t };
  }
}

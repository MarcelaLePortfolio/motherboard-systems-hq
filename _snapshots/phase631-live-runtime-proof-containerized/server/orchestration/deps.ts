export type TaskTerminalState = "SUCCEEDED" | "FAILED" | "CANCELED";

export type TaskLike = {
  id: string;
  state: string;
  dependsOn: string[];
};

export type DepsResolution =
  | { ok: true; blockedBy: string[] }
  | { ok: false; error: string; blockedBy: string[] };

/**
 * Dependency rules (Phase 17.3):
 * - A task is blocked until every id in dependsOn is SUCCEEDED.
 * - If any dependency is FAILED or CANCELED, resolution returns ok:false.
 * - Missing dependency IDs are treated as blocking (unknown).
 */
export function resolveDependencies(task: TaskLike, byId: Map<string, TaskLike>): DepsResolution {
  const blockedBy: string[] = [];

  for (const depId of task.dependsOn || []) {
    const dep = byId.get(depId);
    if (!dep) {
      blockedBy.push(depId);
      continue;
    }

    if (dep.state === "SUCCEEDED") continue;

    if (dep.state === "FAILED" || dep.state === "CANCELED") {
      return { ok: false, error: `dependency ${depId} is terminal ${dep.state}`, blockedBy: [depId] };
    }

    blockedBy.push(depId);
  }

  return { ok: true, blockedBy };
}

export function isRunnable(task: TaskLike, byId: Map<string, TaskLike>): { runnable: boolean; blockedBy: string[]; terminalBlock?: string } {
  const r = resolveDependencies(task, byId);
  if (!r.ok) return { runnable: false, blockedBy: r.blockedBy, terminalBlock: r.error };
  return { runnable: r.blockedBy.length === 0, blockedBy: r.blockedBy };
}

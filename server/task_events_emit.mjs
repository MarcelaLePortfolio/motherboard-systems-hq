import { appendTaskEvent } from "./task-events.mjs";
console.log("[phase25] task_events_emit loaded", new Date().toISOString(), "file=", import.meta.url);
function ms() { return Date.now(); }

export async function emitTaskEvent({ pool, kind, task_id, run_id = null, actor = null, payload = null }) {
  console.log("[phase25] emitTaskEvent ENTER", { ts: Date.now(), kind, task_id, hasGlobal: !!globalThis.__DB_POOL, globalType: globalThis.__DB_POOL?.constructor?.name });
  // [phase25] tolerate import-order: allow callers to omit pool and use global singleton
  pool = pool || globalThis.__DB_POOL;
  console.log("[phase25] emitTaskEvent BEFORE CHECK", { hasArg: !!pool, hasGlobal: !!globalThis.__DB_POOL, globalType: globalThis.__DB_POOL?.constructor?.name, argType: pool?.constructor?.name });
  console.log("[phase25] emitTaskEvent pool", { arg: !!pool, argType: pool?.constructor?.name, hasGlobal: !!globalThis.__DB_POOL, globalType: globalThis.__DB_POOL?.constructor?.name });

    // [phase25] tolerate import-order: allow callers to omit pool and use global singleton
if (!pool) throw new Error("emitTaskEvent: pool required");
  if (!kind) throw new Error("emitTaskEvent: kind required");

  const obj = {
    task_id: task_id ?? null,
    run_id: run_id ?? null,
    actor: actor ?? null,
    ts: ms(),
    ...(payload && typeof payload === "object" ? payload : {}),
  };

  return appendTaskEvent(pool, kind, obj);
}
export async function writeTaskEvent(pool, kind, obj) {
  if (!pool) throw new Error("writeTaskEvent: pool required");
  if (!kind) throw new Error("writeTaskEvent: kind required");
  return appendTaskEvent(pool, kind, obj);
}

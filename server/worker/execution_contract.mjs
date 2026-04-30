const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');
function isObject(v) {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

export function validateTask(task = {}) {
  if (!isObject(task)) {
    return { ok: false, error: "TASK_NOT_OBJECT" };
  }

  return {
    ok: true,
    task: {
      id: task.id || null,
      task_id: task.task_id || null,
      title: task.title || null,
      payload: task.payload || null,
      meta: isObject(task.meta) ? task.meta : {}
    }
  };
}

export function validateExecutionResult(result = {}) {
  if (!isObject(result)) {
    return { ok: false, error: "EXECUTION_NOT_OBJECT" };
  }

  const allowedStrategies = new Set([
    "default",
    "prompt_augmentation"
  ]);

  const strategy = result.strategy_applied || "default";

  if (!allowedStrategies.has(strategy)) {
    return {
      ok: false,
      error: "INVALID_STRATEGY",
      strategy
    };
  }

  return {
    ok: true,
    execution: {
      ok: Boolean(result.ok),
      strategy_applied: strategy,
      notes: result.notes || "",
      output: result.output || "",
      meta: isObject(result.meta) ? result.meta : {}
    }
  };
}

export function safeExecutionContract(task, executionResult) {
  const t = validateTask(task);
  if (!t.ok) return t;

  const e = validateExecutionResult(executionResult);
  if (!e.ok) return e;

  return {
    ok: true,
    task: t.task,
    execution: e.execution
  };
}

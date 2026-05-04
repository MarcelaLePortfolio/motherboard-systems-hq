export function resolveExecutionPolicy(task = {}) {
  const payload =
    task && task.payload && typeof task.payload === "object" && !Array.isArray(task.payload)
      ? task.payload
      : {};

  const executionMode = payload.execution_mode || "standard";
  const cachePolicy = payload.cache_policy || "reuse";
  const memoryScope = payload.memory_scope || "preserve";
  const retryOfTaskId = payload.retry_of_task_id || null;

  return {
    is_retry: Boolean(retryOfTaskId),
    retry_of_task_id: retryOfTaskId,
    execution_mode: executionMode,
    cache_policy: cachePolicy,
    memory_scope: memoryScope,
    requires_context_rebuild: executionMode === "rebuild_context",
    requires_cache_bypass: cachePolicy === "bypass",
    requires_memory_scope_reset: memoryScope === "reset_partial"
  };
}

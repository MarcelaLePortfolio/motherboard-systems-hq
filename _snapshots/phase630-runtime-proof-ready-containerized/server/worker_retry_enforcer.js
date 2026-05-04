function enforceWorkerRetryContract(task) {
  if (!task) return task;

  if (task.kind !== "retry") return task;

  const mode = task.execution_mode || "standard_retry";

  if (mode === "fresh-context") {
    task.cache_policy = "bypass";
    task.memory_scope = "reset_partial";
    task.execution_mode = "rebuild_context";
  } else {
    task.cache_policy = "reuse";
    task.memory_scope = "preserve";
    task.execution_mode = "standard_retry";
  }

  task._enforced_at_worker = true;
  return task;
}

module.exports = { enforceWorkerRetryContract };

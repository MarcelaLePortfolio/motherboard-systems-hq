function routeRetryExecution(task) {
  const strategy = task?.strategy || "standard";

  if (strategy === "fresh-context") {
    return {
      ...task,
      execution_mode: "rebuild_context",
      cache_policy: "bypass",
      memory_scope: "reset_partial"
    };
  }

  return {
    ...task,
    execution_mode: "standard_retry",
    cache_policy: "reuse",
    memory_scope: "preserve"
  };
}

module.exports = { routeRetryExecution };

function normalizeString(value, fallback = "") {
  const text = String(value ?? "").trim();
  return text || fallback;
}

function extractExecution(contractedExecution = {}) {
  if (contractedExecution?.execution && typeof contractedExecution.execution === "object") {
    return contractedExecution.execution;
  }

  return {};
}

export function compileCommunicationResult(task = {}, contractedExecution = {}, options = {}) {
  const execution = extractExecution(contractedExecution);

  const taskId = task.task_id ?? task.id ?? null;
  const runId = task.run_id ?? null;

  const outcomeContent = normalizeString(
    execution.output,
    "Execution completed."
  );

  const explanationContent = normalizeString(
    execution.notes,
    "No additional explanation available."
  );

  const strategyApplied = normalizeString(
    execution.strategy_applied,
    "default"
  );

  return {
    outcome: {
      tier: "TIER_1",
      purpose: "operator-safe outcome",
      content: outcomeContent,
      visibility: "default"
    },

    explanation: {
      tier: "TIER_2",
      purpose: "brief causal explanation",
      content: explanationContent,
      visibility: "on_request",
      persistence: "non_sticky"
    },

    systemTrace: {
      tier: "TIER_3",
      purpose: "internal/system execution trace",
      content: {
        task_id: taskId,
        run_id: runId,
        strategy_applied: strategyApplied,
        execution_meta: execution.meta && typeof execution.meta === "object" ? execution.meta : {},
        compiler_options: options && typeof options === "object" ? options : {}
      },
      visibility: "explicit_access_only",
      persistence: "non_default"
    }
  };
}

export default compileCommunicationResult;

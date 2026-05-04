import { interpretTaskExecution } from "./task_execution_interpreter.mjs";
import { safeExecutionContract } from "./execution_contract.mjs";
import { compileCommunicationResult } from "./response_compiler.mjs";

export function executeTaskWithContract(task) {
  const executionResult = interpretTaskExecution(task);
  const contractedExecution = safeExecutionContract(task, executionResult);

  if (!contractedExecution.ok) {
    throw new Error(`[worker][execution-contract] ${contractedExecution.error || "EXECUTION_CONTRACT_FAILED"}`);
  }

  console.log("[worker][execution-contract]", {
    task_id: task.task_id,
    strategy_applied: contractedExecution.execution.strategy_applied,
    notes: contractedExecution.execution.notes,
    output: contractedExecution.execution.output
  });

  const communicationResult = compileCommunicationResult(task, contractedExecution);

  console.log("[worker][response-compiler]", {
    task_id: task.task_id,
    outcome_preview: communicationResult.outcome.content,
    explanation_preview: communicationResult.explanation.content
  });

  return {
    ...contractedExecution,
    communicationResult
  };
}

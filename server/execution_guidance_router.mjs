export function classifyExecutionOutcome(communicationResult = {}) {
  const outcome = String(communicationResult.outcome || '').toLowerCase();
  const explanation = String(communicationResult.explanation || '').toLowerCase();

  if (
    outcome.includes('blocked') ||
    explanation.includes('blocked') ||
    explanation.includes('missing') ||
    explanation.includes('requires') ||
    explanation.includes('cannot proceed')
  ) {
    return 'blocked';
  }

  if (
    outcome.includes('retry') ||
    explanation.includes('retry') ||
    explanation.includes('temporary') ||
    explanation.includes('failed') ||
    explanation.includes('timeout')
  ) {
    return 'retryable';
  }

  if (
    outcome.includes('success') ||
    outcome.includes('complete') ||
    explanation.includes('completed') ||
    explanation.includes('success')
  ) {
    return 'success';
  }

  return 'unknown';
}

export function interpretCompletedTaskEvent(event = {}) {
  const payload = event.payload || {};
  const communicationResult =
    payload.communicationResult ||
    payload.communication_result ||
    event.communicationResult ||
    {};

  const classification = classifyExecutionOutcome(communicationResult);

  return {
    taskId: payload.task_id || payload.taskId || event.task_id || null,
    runId: payload.run_id || payload.runId || event.run_id || null,
    classification,
    outcome: communicationResult.outcome || null,
    explanation: communicationResult.explanation || null,
    interpretedAt: new Date().toISOString(),
  };
}

export function logExecutionGuidanceInterpretation(event = {}) {
  const interpretation = interpretCompletedTaskEvent(event);

  console.log('[execution-guidance]', JSON.stringify({
    mode: 'passive',
    sideEffects: false,
    ...interpretation,
  }));

  return interpretation;
}

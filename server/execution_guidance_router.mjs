function textFrom(value) {
  if (value == null) return "";

  if (typeof value === "string") return value;

  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }

  if (typeof value === "object") {
    return [
      value.tier,
      value.content,
      value.purpose,
      value.visibility,
      value.persistence
    ]
      .filter(Boolean)
      .map(String)
      .join(" ");
  }

  return "";
}

export function classifyExecutionOutcome(communicationResult = {}) {
  const outcome = textFrom(communicationResult.outcome).toLowerCase();
  const explanation = textFrom(communicationResult.explanation).toLowerCase();
  const combined = `${outcome} ${explanation}`.trim();

  if (!combined) {
    return 'unknown';
  }

  if (
    combined.includes('blocked') ||
    combined.includes('missing') ||
    combined.includes('requires') ||
    combined.includes('cannot proceed')
  ) {
    return 'blocked';
  }

  if (
    combined.includes('retry') ||
    combined.includes('temporary') ||
    combined.includes('failed') ||
    combined.includes('timeout')
  ) {
    return 'retryable';
  }

  if (
    combined.includes('success') ||
    combined.includes('complete') ||
    combined.includes('completed') ||
    combined.includes('prepared') ||
    combined.includes('standard execution')
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

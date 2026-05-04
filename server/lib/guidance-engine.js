/**
 * PHASE 659 — GUIDANCE PRIORITIZATION (READ-ONLY)
 */

function createGuidance({ type, severity, message, subsystem, suggested_action }) {
  return {
    type,
    severity,
    message,
    subsystem,
    suggested_action: suggested_action || null,
    generated_at: new Date().toISOString()
  };
}

function sortByPriority(guidance) {
  return guidance.sort((a, b) => b.severity - a.severity);
}

export function generateGuidance(subsystems) {
  const guidance = [];

  const atlas = subsystems.find((s) => s.name === 'atlas');
  const execution = subsystems.find((s) => s.name === 'execution');

  if (atlas && !atlas.connected) {
    guidance.push(
      createGuidance({
        type: 'info',
        severity: 1,
        message: 'Atlas is not running (optional subsystem).',
        subsystem: 'atlas',
        suggested_action: 'Start the Atlas container if Atlas-specific observability is needed.'
      })
    );
  }

  if (execution && execution.status !== 'verified') {
    guidance.push(
      createGuidance({
        type: 'critical',
        severity: 3,
        message: 'Execution subsystem is not verified.',
        subsystem: 'execution',
        suggested_action: 'Pause execution-facing changes until runtime integrity is confirmed.'
      })
    );
  }

  if (guidance.length === 0) {
    guidance.push(
      createGuidance({
        type: 'info',
        severity: 1,
        message: 'All monitored subsystems are operating normally.',
        subsystem: 'all'
      })
    );
  }

  return sortByPriority(guidance);
}

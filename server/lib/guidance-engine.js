/**
 * PHASE 651 — GUIDANCE SIGNAL REFINEMENT (READ-ONLY)
 */

function createGuidance({ type, severity, message, subsystem }) {
  return {
    type,
    severity,
    message,
    subsystem,
    generated_at: new Date().toISOString()
  };
}

export function generateGuidance(subsystems) {
  const guidance = [];

  const atlas = subsystems.find((s) => s.name === 'atlas');
  const execution = subsystems.find((s) => s.name === 'execution');

  if (atlas && !atlas.connected) {
    guidance.push(
      createGuidance({
        type: 'warning',
        severity: 2,
        message: 'Atlas subsystem is not detected. Verify container status before relying on Atlas-specific observability.',
        subsystem: 'atlas'
      })
    );
  }

  if (execution && execution.status !== 'verified') {
    guidance.push(
      createGuidance({
        type: 'critical',
        severity: 3,
        message: 'Execution subsystem is not verified. Pause execution-facing changes until runtime integrity is confirmed.',
        subsystem: 'execution'
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

  return guidance;
}

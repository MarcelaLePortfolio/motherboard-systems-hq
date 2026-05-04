/**
 * PHASE 650 — BASIC GUIDANCE ENGINE (READ-ONLY)
 */

export function generateGuidance(subsystems) {
  const guidance = [];

  const atlas = subsystems.find((s) => s.name === 'atlas');
  const execution = subsystems.find((s) => s.name === 'execution');

  if (atlas && !atlas.connected) {
    guidance.push({
      type: 'warning',
      message: 'Atlas is not detected. Check container status.',
      subsystem: 'atlas'
    });
  }

  if (execution && execution.status !== 'verified') {
    guidance.push({
      type: 'warning',
      message: 'Execution subsystem not verified.',
      subsystem: 'execution'
    });
  }

  if (guidance.length === 0) {
    guidance.push({
      type: 'info',
      message: 'All subsystems operating normally.',
      subsystem: 'all'
    });
  }

  return guidance;
}

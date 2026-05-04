// Phase 674 — Guidance Coherence Adapter
// Non-runtime adapter only. No SSE, UI, formatting, or execution coupling.

import coherenceEngine from './coherence-engine.mjs';

export function prepareGuidanceHistoryForCoherence(history = []) {
  if (!Array.isArray(history)) {
    return [];
  }

  return history
    .filter(Boolean)
    .filter(evt => evt.timestamp)
    .map(evt => ({
      timestamp: evt.timestamp,
      task_id: evt.task_id || evt.taskId || 'global',
      subsystem: evt.subsystem || evt.source || 'guidance',
      signal_type: evt.signal_type || evt.type || 'generic',
      severity: evt.severity || 'info',
      message: evt.message || evt.summary || '',
    }));
}

export function deriveCoherentGuidance(history = []) {
  const prepared = prepareGuidanceHistoryForCoherence(history);
  return coherenceEngine(prepared);
}

export default deriveCoherentGuidance;

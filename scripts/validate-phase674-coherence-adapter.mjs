import {
  prepareGuidanceHistoryForCoherence,
  deriveCoherentGuidance,
} from '../server/guidance/coherence-adapter.mjs';

const rawHistory = [
  {
    timestamp: '2026-05-04T18:00:00.000Z',
    taskId: 'task-2',
    source: 'operator-guidance',
    type: 'duplicate-risk',
    severity: 'warning',
    summary: 'Repeated guidance signal detected',
  },
  {
    timestamp: '2026-05-04T18:01:00.000Z',
    taskId: 'task-2',
    source: 'operator-guidance',
    type: 'duplicate-risk',
    severity: 'warning',
    summary: 'Repeated guidance signal detected',
  },
  {
    timestamp: '2026-05-04T18:02:00.000Z',
    taskId: 'task-2',
    source: 'operator-guidance',
    type: 'duplicate-risk',
    severity: 'warning',
    summary: 'Repeated guidance signal detected',
  },
];

const prepared = prepareGuidanceHistoryForCoherence(rawHistory);
const coherent = deriveCoherentGuidance(rawHistory);

if (prepared.length !== 3) {
  throw new Error(`Expected 3 prepared events, received ${prepared.length}`);
}

if (prepared[0].task_id !== 'task-2') {
  throw new Error(`Expected task_id task-2, received ${prepared[0].task_id}`);
}

if (prepared[0].subsystem !== 'operator-guidance') {
  throw new Error(`Expected subsystem operator-guidance, received ${prepared[0].subsystem}`);
}

if (prepared[0].signal_type !== 'duplicate-risk') {
  throw new Error(`Expected signal_type duplicate-risk, received ${prepared[0].signal_type}`);
}

if (coherent.length !== 1) {
  throw new Error(`Expected 1 coherent signal, received ${coherent.length}`);
}

if (coherent[0].count !== 3) {
  throw new Error(`Expected coherent count of 3, received ${coherent[0].count}`);
}

if (coherent[0].normalized_severity !== 'elevated') {
  throw new Error(`Expected elevated severity, received ${coherent[0].normalized_severity}`);
}

console.log('Phase 674 coherence adapter validation passed');
console.log(JSON.stringify({
  prepared: prepared.length,
  coherent: coherent.length,
  count: coherent[0].count,
  normalized_severity: coherent[0].normalized_severity,
}, null, 2));

import {
  buildIdentityKey,
  groupByTimeWindow,
  deduplicate,
  normalize,
  coherenceEngine,
} from '../server/guidance/coherence-engine.mjs';

const history = [
  {
    timestamp: '2026-05-04T18:00:00.000Z',
    task_id: 'task-1',
    subsystem: 'guidance',
    signal_type: 'retry-risk',
    severity: 'warning',
  },
  {
    timestamp: '2026-05-04T18:01:00.000Z',
    task_id: 'task-1',
    subsystem: 'guidance',
    signal_type: 'retry-risk',
    severity: 'warning',
  },
  {
    timestamp: '2026-05-04T18:02:00.000Z',
    task_id: 'task-1',
    subsystem: 'guidance',
    signal_type: 'retry-risk',
    severity: 'warning',
  },
];

const key = buildIdentityKey(history[0]);
const windows = groupByTimeWindow(history);
const deduped = deduplicate(history);
const normalized = normalize(deduped);
const coherent = coherenceEngine(history);

if (key !== 'task-1::guidance::retry-risk') {
  throw new Error(`Unexpected identity key: ${key}`);
}

if (windows.length !== 1) {
  throw new Error(`Expected 1 time window, received ${windows.length}`);
}

if (deduped.length !== 1) {
  throw new Error(`Expected 1 deduplicated signal, received ${deduped.length}`);
}

if (deduped[0].count !== 3) {
  throw new Error(`Expected deduplicated count of 3, received ${deduped[0].count}`);
}

if (normalized[0].normalized_severity !== 'elevated') {
  throw new Error(`Expected elevated severity, received ${normalized[0].normalized_severity}`);
}

if (coherent.length !== 1 || coherent[0].normalized_severity !== 'elevated') {
  throw new Error('Coherence engine output failed validation');
}

console.log('Phase 674 coherence validation passed');
console.log(JSON.stringify({ key, windows: windows.length, deduped: deduped.length, normalized_severity: normalized[0].normalized_severity }, null, 2));

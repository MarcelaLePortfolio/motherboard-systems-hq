// Phase 674 — Guidance Coherence Engine (Isolated Derived Layer)
// Input: array of guidance events (history)
// Output: coherence-enhanced guidance (derived only, no mutation)

export function buildIdentityKey(evt) {
  const task = evt.task_id || 'global';
  const subsystem = evt.subsystem || 'unknown';
  const signal = evt.signal_type || 'generic';
  return `${task}::${subsystem}::${signal}`;
}

export function groupByTimeWindow(events, windowMs = 5 * 60 * 1000) {
  const sorted = [...events].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  const groups = [];
  let current = [];

  for (const evt of sorted) {
    if (!current.length) {
      current.push(evt);
      continue;
    }
    const last = current[current.length - 1];
    const dt = new Date(evt.timestamp) - new Date(last.timestamp);
    if (dt <= windowMs) {
      current.push(evt);
    } else {
      groups.push(current);
      current = [evt];
    }
  }
  if (current.length) groups.push(current);
  return groups;
}

export function deduplicate(events) {
  const map = new Map();
  for (const evt of events) {
    const key = buildIdentityKey(evt);
    const existing = map.get(key);
    if (!existing) {
      map.set(key, { ...evt, first_seen: evt.timestamp, last_seen: evt.timestamp, count: 1 });
    } else {
      existing.last_seen = evt.timestamp;
      existing.count += 1;
      map.set(key, existing);
    }
  }
  return Array.from(map.values());
}

export function normalize(events) {
  return events.map(evt => {
    let severity = evt.severity || 'info';
    if (evt.count >= 3 && severity === 'warning') severity = 'elevated';
    if (evt.count >= 5) severity = 'critical';

    return {
      ...evt,
      normalized_severity: severity,
      consistency_flag: false, // placeholder for future conflict detection
    };
  });
}

export function coherenceEngine(history) {
  const windows = groupByTimeWindow(history);
  const flattened = windows.flat();
  const deduped = deduplicate(flattened);
  const normalized = normalize(deduped);

  return normalized;
}

export default coherenceEngine;

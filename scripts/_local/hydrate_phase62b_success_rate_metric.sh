#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_SUCCESS_RATE_HYDRATION"

block = r"""
;/* PHASE62B_SUCCESS_RATE_HYDRATION */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_SUCCESS_RATE_HYDRATION__) return;
  window.__PHASE62B_SUCCESS_RATE_HYDRATION__ = true;

  let completedCount = 0;
  let failedCount = 0;
  const seenTerminalEvents = new Set();

  const terminalSuccessTypes = new Set(['completed', 'complete', 'done', 'success']);
  const terminalFailureTypes = new Set([
    'failed',
    'error',
    'cancelled',
    'canceled',
    'timed_out',
    'timeout',
    'terminated',
    'aborted'
  ]);

  const normalize = (value) =>
    String(value || '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, '_');

  const safeJsonParse = (value) => {
    try {
      return JSON.parse(value);
    } catch {
      return null;
    }
  };

  const getTaskId = (payload) =>
    payload?.task_id ??
    payload?.taskId ??
    payload?.id ??
    payload?.data?.task_id ??
    payload?.data?.taskId ??
    null;

  const getEventType = (eventName, payload) =>
    normalize(
      payload?.type ??
      payload?.event ??
      payload?.status ??
      payload?.state ??
      eventName
    );

  const getEventTs = (payload) =>
    payload?.ts ??
    payload?.timestamp ??
    payload?.at ??
    payload?.time ??
    payload?.created_at ??
    payload?.updated_at ??
    'na';

  const metricValueSelectors = [
    '[data-metric-value]',
    '[data-value]',
    '.metric-value',
    '.telemetry-value',
    '.stat-value',
    '.value'
  ].join(',');

  const containerSelectors = [
    '.metric-card',
    '.telemetry-tile',
    '.metric-tile',
    '.metrics-tile',
    '[data-metric-label]',
    '[data-metric-key]',
    '#metrics-row > *',
    '.metrics-row > *',
    '#metrics-row .card',
    '.metrics-row .card',
    '#metrics-row .tile',
    '.metrics-row .tile'
  ].join(',');

  const findSuccessRateValueNode = () => {
    const containers = Array.from(document.querySelectorAll(containerSelectors));

    for (const el of containers) {
      const labelSource = [
        el.getAttribute?.('data-metric-label') || '',
        el.getAttribute?.('data-metric-key') || '',
        el.textContent || ''
      ].join(' ').toLowerCase();

      if (!labelSource.includes('success rate')) continue;

      const explicitValue = el.querySelector?.(metricValueSelectors);
      if (explicitValue) return explicitValue;
      return el;
    }

    const textNodes = Array.from(document.querySelectorAll('div,span,p,strong,h2,h3,h4'));
    for (const node of textNodes) {
      if ((node.textContent || '').trim().toLowerCase() !== 'success rate') continue;

      const valueNode =
        node.parentElement?.querySelector?.(metricValueSelectors) ||
        node.nextElementSibling ||
        node.parentElement;

      if (valueNode) return valueNode;
    }

    return null;
  };

  const render = () => {
    const node = findSuccessRateValueNode();
    if (!node) return;

    const total = completedCount + failedCount;
    if (total <= 0) {
      node.textContent = '—';
      return;
    }

    const pct = Math.round((completedCount / total) * 100);
    node.textContent = `${pct}%`;
  };

  const ingestEvent = (eventName, payload) => {
    const eventType = getEventType(eventName, payload);
    const taskId = getTaskId(payload) || 'unknown';
    const eventTs = getEventTs(payload);
    const dedupeKey = `${taskId}|${eventType}|${eventTs}`;

    if (terminalSuccessTypes.has(eventType)) {
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);
        completedCount += 1;
      }
      render();
      return;
    }

    if (terminalFailureTypes.has(eventType)) {
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);
        failedCount += 1;
      }
      render();
      return;
    }

    render();
  };

  const ingestMessage = (raw, forcedEventName = null) => {
    const parsed = typeof raw === 'string' ? safeJsonParse(raw) : raw;
    if (!parsed) return;

    if (Array.isArray(parsed)) {
      parsed.forEach((item) => ingestEvent(forcedEventName, item));
      return;
    }

    const candidateLists = [
      parsed?.events,
      parsed?.payload?.events,
      parsed?.task_events,
      parsed?.items
    ];

    for (const list of candidateLists) {
      if (Array.isArray(list)) {
        list.forEach((item) => ingestEvent(forcedEventName, item));
        return;
      }
    }

    ingestEvent(
      forcedEventName ?? parsed?.event ?? parsed?.type ?? parsed?.status,
      parsed?.payload ?? parsed?.data ?? parsed
    );
  };

  const attachTypedListener = (es, eventName) => {
    es.addEventListener(eventName, (evt) => {
      const parsed = safeJsonParse(evt.data);
      if (parsed !== null) {
        ingestMessage({ event: eventName, payload: parsed }, eventName);
      } else {
        ingestMessage({ event: eventName, payload: { type: eventName } }, eventName);
      }
    });
  };

  const connect = () => {
    let es;
    try {
      es = new EventSource('/events/task-events');
    } catch {
      render();
      return;
    }

    es.onmessage = (evt) => ingestMessage(evt.data);

    [
      'completed',
      'complete',
      'done',
      'success',
      'failed',
      'error',
      'cancelled',
      'canceled',
      'timed_out',
      'timeout',
      'terminated',
      'aborted'
    ].forEach((eventName) => attachTypedListener(es, eventName));

    es.onerror = () => render();
    window.addEventListener('beforeunload', () => es.close(), { once: true });
  };

  render();
  connect();
  window.setInterval(render, 10000);
})();
"""

for path in targets:
    if not path.exists():
        raise SystemExit(f"missing target: {path}")

    original = path.read_text()
    if marker in original:
        continue

    path.write_text(original.rstrip() + "\n" + block.strip() + "\n")
    print(f"patched {path}")
PY

#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGETS=(
  "public/js/agent-status-row.js"
  "public/bundle.js"
)

python3 <<'PY'
from pathlib import Path

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_TASKS_RUNNING_HYDRATION"

block = r"""
;/* PHASE62B_TASKS_RUNNING_HYDRATION */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_TASKS_RUNNING_HYDRATION__) return;
  window.__PHASE62B_TASKS_RUNNING_HYDRATION__ = true;

  const runningTaskIds = new Set();
  const runningTypes = new Set([
    'created',
    'queued',
    'leased',
    'started',
    'running',
    'in_progress',
    'delegated',
    'retrying'
  ]);
  const terminalTypes = new Set([
    'completed',
    'failed',
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
    '.metrics-row > *',
    '.metrics-row .card',
    '.metrics-row .tile'
  ].join(',');

  const findTasksRunningValueNode = () => {
    const containers = Array.from(document.querySelectorAll(containerSelectors));

    for (const el of containers) {
      const labelSource = [
        el.getAttribute?.('data-metric-label') || '',
        el.getAttribute?.('data-metric-key') || '',
        el.textContent || ''
      ].join(' ').toLowerCase();

      if (!labelSource.includes('tasks running')) continue;

      const explicitValue = el.querySelector?.(metricValueSelectors);
      if (explicitValue) return explicitValue;
      return el;
    }

    const textNodes = Array.from(document.querySelectorAll('div,span,p,strong,h2,h3,h4'));
    for (const node of textNodes) {
      if ((node.textContent || '').trim().toLowerCase() !== 'tasks running') continue;

      const valueNode =
        node.parentElement?.querySelector?.(metricValueSelectors) ||
        node.nextElementSibling ||
        node.parentElement;

      if (valueNode) return valueNode;
    }

    return null;
  };

  const render = () => {
    const node = findTasksRunningValueNode();
    if (!node) return;
    node.textContent = String(runningTaskIds.size);
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);

    if (!taskId) {
      render();
      return;
    }

    if (terminalTypes.has(eventType)) {
      runningTaskIds.delete(taskId);
      render();
      return;
    }

    if (runningTypes.has(eventType)) {
      runningTaskIds.add(taskId);
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
      'created',
      'queued',
      'leased',
      'started',
      'running',
      'in_progress',
      'delegated',
      'retrying',
      'completed',
      'failed',
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

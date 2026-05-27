#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_LATENCY_HYDRATION"

block = r"""
;/* PHASE62B_LATENCY_HYDRATION */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE62B_LATENCY_HYDRATION__) return;
  window.__PHASE62B_LATENCY_HYDRATION__ = true;

  const taskStartTimes = new Map();
  const seenTerminalEvents = new Set();
  const recentDurationsMs = [];
  const maxSamples = 50;

  const startTypes = new Set([
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

  const toMs = (value) => {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value > 1e12 ? value : value * 1000;
    }

    if (typeof value === 'string' && value.trim()) {
      const asNum = Number(value);
      if (Number.isFinite(asNum)) {
        return asNum > 1e12 ? asNum : asNum * 1000;
      }

      const parsed = Date.parse(value);
      if (Number.isFinite(parsed)) return parsed;
    }

    return Date.now();
  };

  const getEventTs = (payload) =>
    toMs(
      payload?.ts ??
      payload?.timestamp ??
      payload?.at ??
      payload?.time ??
      payload?.created_at ??
      payload?.updated_at ??
      Date.now()
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
    '#metrics-row > *',
    '.metrics-row > *',
    '#metrics-row .card',
    '.metrics-row .card',
    '#metrics-row .tile',
    '.metrics-row .tile'
  ].join(',');

  const findLatencyValueNode = () => {
    const containers = Array.from(document.querySelectorAll(containerSelectors));

    for (const el of containers) {
      const labelSource = [
        el.getAttribute?.('data-metric-label') || '',
        el.getAttribute?.('data-metric-key') || '',
        el.textContent || ''
      ].join(' ').toLowerCase();

      if (!labelSource.includes('latency')) continue;

      const explicitValue = el.querySelector?.(metricValueSelectors);
      if (explicitValue) return explicitValue;
      return el;
    }

    const textNodes = Array.from(document.querySelectorAll('div,span,p,strong,h2,h3,h4'));
    for (const node of textNodes) {
      if ((node.textContent || '').trim().toLowerCase() !== 'latency') continue;

      const valueNode =
        node.parentElement?.querySelector?.(metricValueSelectors) ||
        node.nextElementSibling ||
        node.parentElement;

      if (valueNode) return valueNode;
    }

    return null;
  };

  const formatLatency = (ms) => {
    if (!Number.isFinite(ms) || ms <= 0) return '—';
    if (ms < 1000) return `${Math.round(ms)}ms`;
    const seconds = ms / 1000;
    if (seconds < 60) return `${seconds.toFixed(seconds >= 10 ? 0 : 1)}s`;
    const minutes = seconds / 60;
    return `${minutes.toFixed(minutes >= 10 ? 0 : 1)}m`;
  };

  const render = () => {
    const node = findLatencyValueNode();
    if (!node) return;

    if (!recentDurationsMs.length) {
      node.textContent = '—';
      return;
    }

    const avg =
      recentDurationsMs.reduce((sum, value) => sum + value, 0) /
      recentDurationsMs.length;

    node.textContent = formatLatency(avg);
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);
    const eventTs = getEventTs(payload);

    if (!taskId) {
      render();
      return;
    }

    if (startTypes.has(eventType) && !taskStartTimes.has(taskId)) {
      taskStartTimes.set(taskId, eventTs);
      render();
      return;
    }

    if (terminalTypes.has(eventType)) {
      const dedupeKey = `${taskId}|${eventType}|${eventTs}`;
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);

        const startTs = taskStartTimes.get(taskId);
        if (Number.isFinite(startTs)) {
          const duration = Math.max(0, eventTs - startTs);
          recentDurationsMs.push(duration);
          if (recentDurationsMs.length > maxSamples) {
            recentDurationsMs.splice(0, recentDurationsMs.length - maxSamples);
          }
        }

        taskStartTimes.delete(taskId);
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
      'created',
      'queued',
      'leased',
      'started',
      'running',
      'in_progress',
      'delegated',
      'retrying',
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

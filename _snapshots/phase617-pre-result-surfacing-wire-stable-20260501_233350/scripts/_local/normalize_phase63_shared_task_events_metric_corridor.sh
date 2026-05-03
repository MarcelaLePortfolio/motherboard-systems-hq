#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

markers_to_remove = [
    "PHASE62B_TASKS_RUNNING_HYDRATION",
    "PHASE62B_SUCCESS_RATE_HYDRATION",
    "PHASE62B_LATENCY_HYDRATION",
]

block = r"""
;/* PHASE63_SHARED_TASK_EVENTS_METRICS */
(() => {
  if (typeof window === 'undefined') return;
  if (window.__PHASE63_SHARED_TASK_EVENTS_METRICS__) return;
  window.__PHASE63_SHARED_TASK_EVENTS_METRICS__ = true;

  const tasksNode = document.getElementById('metric-tasks');
  const successNode = document.getElementById('metric-success');
  const latencyNode = document.getElementById('metric-latency');

  const runningTaskIds = new Set();
  const taskStartTimes = new Map();
  const seenTerminalEvents = new Set();
  const recentDurationsMs = [];
  const maxSamples = 50;

  let completedCount = 0;
  let failedCount = 0;

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

  const terminalSuccessTypes = new Set([
    'completed',
    'complete',
    'done',
    'success'
  ]);

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

  const terminalTypes = new Set([
    ...terminalSuccessTypes,
    ...terminalFailureTypes
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

  const formatLatency = (ms) => {
    if (!Number.isFinite(ms) || ms <= 0) return '—';
    if (ms < 1000) return `${Math.round(ms)}ms`;
    const seconds = ms / 1000;
    if (seconds < 60) return `${seconds.toFixed(seconds >= 10 ? 0 : 1)}s`;
    const minutes = seconds / 60;
    return `${minutes.toFixed(minutes >= 10 ? 0 : 1)}m`;
  };

  const render = () => {
    if (tasksNode) {
      tasksNode.textContent = String(runningTaskIds.size);
    }

    if (successNode) {
      const total = completedCount + failedCount;
      successNode.textContent = total > 0
        ? `${Math.round((completedCount / total) * 100)}%`
        : '—';
    }

    if (latencyNode) {
      if (!recentDurationsMs.length) {
        latencyNode.textContent = '—';
      } else {
        const avg =
          recentDurationsMs.reduce((sum, value) => sum + value, 0) /
          recentDurationsMs.length;
        latencyNode.textContent = formatLatency(avg);
      }
    }
  };

  const ingestEvent = (eventName, payload) => {
    const taskId = getTaskId(payload);
    const eventType = getEventType(eventName, payload);
    const eventTs = getEventTs(payload);

    if (!taskId) {
      render();
      return;
    }

    if (runningTypes.has(eventType)) {
      runningTaskIds.add(taskId);
      if (!taskStartTimes.has(taskId)) {
        taskStartTimes.set(taskId, eventTs);
      }
    }

    if (terminalTypes.has(eventType)) {
      runningTaskIds.delete(taskId);

      const dedupeKey = `${taskId}|${eventType}|${eventTs}`;
      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);

        if (terminalSuccessTypes.has(eventType)) completedCount += 1;
        if (terminalFailureTypes.has(eventType)) failedCount += 1;

        const startTs = taskStartTimes.get(taskId);
        if (Number.isFinite(startTs)) {
          const duration = Math.max(0, eventTs - startTs);
          recentDurationsMs.push(duration);
          if (recentDurationsMs.length > maxSamples) {
            recentDurationsMs.splice(0, recentDurationsMs.length - maxSamples);
          }
        }
      }

      taskStartTimes.delete(taskId);
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
      ...runningTypes,
      ...terminalSuccessTypes,
      ...terminalFailureTypes
    ].forEach((eventName) => attachTypedListener(es, eventName));

    es.onerror = () => render();
    window.addEventListener('beforeunload', () => es.close(), { once: true });
  };

  render();
  connect();
  window.setInterval(render, 10000);
})();
"""

def remove_marker_block(text: str, marker: str) -> str:
    pattern = re.compile(
        r'\n?;\/\*\s*' + re.escape(marker) + r'\s*\*\/\s*\(\(\)\s*=>\s*\{.*?\}\)\(\);\s*',
        re.DOTALL
    )
    return re.sub(pattern, '\n', text)

for path in targets:
    original = path.read_text()
    updated = original
    for marker in markers_to_remove:
        updated = remove_marker_block(updated, marker)
    updated = remove_marker_block(updated, "PHASE63_SHARED_TASK_EVENTS_METRICS")
    updated = updated.rstrip() + "\n" + block.strip() + "\n"
    path.write_text(updated)
    print(f"patched {path}")
PY

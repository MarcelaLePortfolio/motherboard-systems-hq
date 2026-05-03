# Phase 627 Execution Inspector Location

## Files referencing Execution Inspector
./app/components/ExecutionInspector.tsx:43:export default function ExecutionInspector({ task }: { task: Task }) {
./app/dev/page-ExecutionInspectorTest.tsx:3:import ExecutionInspector from "../components/ExecutionInspector";
./app/dev/page-ExecutionInspectorTest.tsx:8:      <div className="text-lg font-semibold">Execution Inspector — Guidance Test (UI Verified)</div>
./app/dev/page-ExecutionInspectorTest.tsx:10:      <ExecutionInspector
./app/dev/page-ExecutionInspectorTest.tsx:22:      <ExecutionInspector
./app/dev/page-ExecutionInspectorTest.tsx:34:      <ExecutionInspector
./app/dev/page-ExecutionInspectorTest.tsx:46:      <ExecutionInspector
./server.js:68:        source: body.source || "execution-inspector"
./server.js:195:  console.log("Execution Inspector now wired to real task pipeline");
./server/retry_contract.js:29:  body.source = body.source || "execution-inspector";
./public/js/dashboard-tasks-widget.js:452:/* HARD GUARD — protect Execution Inspector from DOM wipes */
./public/js/dashboard-tasks-widget.js:458:      if (this && this.id === "execution-inspector") return;
./public/js/phase538_execution_inspector_retry_strategies.js:26:        source: "execution-inspector",
./public/js/phase533_execution_inspector_layout_fix.js:6:    const inspector = document.getElementById("execution-inspector");
./public/js/phase457_restore_task_panels.js:19:      source: "execution-inspector",
./public/js/phase535_execution_inspector_requeue.js:23:        source: "execution-inspector",
./public/js/phase573_execution_inspector_debug.js:6:    console.log("[execution-inspector-debug]", msg, data || "");
./public/js/phase537_execution_inspector_retry.js:23:        source: "execution-inspector",
./public/js/task-events-sse-client.js:121:        source: "execution-inspector",
./public/js/task-events-sse-client.js:136:        source: "execution-inspector",
./public/js/task-events-sse-client.js:196:        <span>Execution Inspector: ${escapeHtml(state)}</span>
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:276:            source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:278:            notes: "Retry requested from Execution Inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:409:      source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:454:      source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:502:        source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:552:        source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:602:      source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:648:      source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:699:    source: "execution-inspector",
./public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:768:        source: "execution-inspector",
./public/js/phase61_inspector_mount.js:1:/* Execution Inspector — Minimal Deterministic Mount (NO GUARDS, NO OVERLAY SYSTEMS) */
./public/js/phase61_inspector_mount.js:5:  const ID = "execution-inspector";
./public/js/phase61_inspector_mount.js:23:      console.log("[execution-inspector] DOM root mounted");
./public/js/phase61_recent_history_wire.js:2:/* Execution Inspector — Deterministic Mount + Stable Render Contract */
./public/js/phase61_recent_history_wire.js:6:  const INSPECTOR_ID = "execution-inspector";
./public/js/phase61_recent_history_wire.js:30:      console.log("[execution-inspector] deterministic mount created");
./public/js/phase61_recent_history_wire.js:80:      console.log("[execution-inspector] rendered rows:", normalize(data).length);
./public/js/phase61_recent_history_wire.js:82:      console.log("[execution-inspector] fetch error", e);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server.js:68:        source: body.source || "execution-inspector"
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server.js:195:  console.log("Execution Inspector now wired to real task pipeline");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/server/retry_contract.js:29:  body.source = body.source || "execution-inspector";
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/dashboard-tasks-widget.js:445:/* HARD GUARD — protect Execution Inspector from DOM wipes */
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/dashboard-tasks-widget.js:451:      if (this && this.id === "execution-inspector") return;
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase538_execution_inspector_retry_strategies.js:26:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase533_execution_inspector_layout_fix.js:6:    const inspector = document.getElementById("execution-inspector");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.js:19:      source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase535_execution_inspector_requeue.js:23:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase573_execution_inspector_debug.js:6:    console.log("[execution-inspector-debug]", msg, data || "");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase537_execution_inspector_retry.js:23:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/task-events-sse-client.js:121:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/task-events-sse-client.js:136:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/task-events-sse-client.js:196:        <span>Execution Inspector: ${escapeHtml(state)}</span>
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:276:            source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:278:            notes: "Retry requested from Execution Inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:409:      source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:454:      source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:502:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:552:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:602:      source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:648:      source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:699:    source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:768:        source: "execution-inspector",
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_inspector_mount.js:1:/* Execution Inspector — Minimal Deterministic Mount (NO GUARDS, NO OVERLAY SYSTEMS) */
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_inspector_mount.js:5:  const ID = "execution-inspector";
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_inspector_mount.js:23:      console.log("[execution-inspector] DOM root mounted");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:2:/* Execution Inspector — Deterministic Mount + Stable Render Contract */
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:6:  const INSPECTOR_ID = "execution-inspector";
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:30:      console.log("[execution-inspector] deterministic mount created");
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:75:      console.log("[execution-inspector] rendered rows:", normalize(data).length);
./_snapshots/phase617-pre-result-surfacing-wire-stable-20260501_233350/public/js/phase61_recent_history_wire.js:77:      console.log("[execution-inspector] fetch error", e);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server.js:68:        source: body.source || "execution-inspector"
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server.js:195:  console.log("Execution Inspector now wired to real task pipeline");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/server/retry_contract.js:29:  body.source = body.source || "execution-inspector";
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/dashboard-tasks-widget.js:445:/* HARD GUARD — protect Execution Inspector from DOM wipes */
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/dashboard-tasks-widget.js:451:      if (this && this.id === "execution-inspector") return;
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase538_execution_inspector_retry_strategies.js:26:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase533_execution_inspector_layout_fix.js:6:    const inspector = document.getElementById("execution-inspector");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.js:19:      source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase535_execution_inspector_requeue.js:23:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase573_execution_inspector_debug.js:6:    console.log("[execution-inspector-debug]", msg, data || "");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase537_execution_inspector_retry.js:23:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/task-events-sse-client.js:121:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/task-events-sse-client.js:136:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/task-events-sse-client.js:196:        <span>Execution Inspector: ${escapeHtml(state)}</span>
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:276:            source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:278:            notes: "Retry requested from Execution Inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:409:      source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:454:      source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:502:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:552:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:602:      source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:648:      source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:699:    source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:768:        source: "execution-inspector",
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_inspector_mount.js:1:/* Execution Inspector — Minimal Deterministic Mount (NO GUARDS, NO OVERLAY SYSTEMS) */
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_inspector_mount.js:5:  const ID = "execution-inspector";
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_inspector_mount.js:23:      console.log("[execution-inspector] DOM root mounted");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:2:/* Execution Inspector — Deterministic Mount + Stable Render Contract */
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:6:  const INSPECTOR_ID = "execution-inspector";
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:30:      console.log("[execution-inspector] deterministic mount created");
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:80:      console.log("[execution-inspector] rendered rows:", normalize(data).length);
./_snapshots/phase618-ui-communication-tier-surfacing-complete-20260501_235622/public/js/phase61_recent_history_wire.js:82:      console.log("[execution-inspector] fetch error", e);

## Files referencing retry/requeue inspector logic
public/js/phase539_execution_inspector_retry_mode_display.js:12:    const existing = panel.querySelector("[data-retry-mode-display]");
public/js/phase539_execution_inspector_retry_mode_display.js:21:    // Try to infer retry mode from DOM (best-effort, UI-only signal)
public/js/phase539_execution_inspector_retry_mode_display.js:26:    else if (text.includes("standard-retry")) mode = "standard-retry";
public/js/phase539_execution_inspector_retry_mode_display.js:29:    el.setAttribute("data-retry-mode-display", "true");
public/js/phase539_execution_inspector_retry_mode_display.js:35:    el.textContent = "retry_mode: " + mode;
public/js/phase538_execution_inspector_retry_strategies.js:9:    const btn = panel.querySelector('[data-action="retry"]');
public/js/phase538_execution_inspector_retry_strategies.js:22:      const strategy = e.shiftKey ? "fresh-context" : "standard-retry";
public/js/phase538_execution_inspector_retry_strategies.js:27:        kind: "retry",
public/js/phase538_execution_inspector_retry_strategies.js:29:          retry_of_task_id: taskId,
public/js/phase538_execution_inspector_retry_strategies.js:30:          retry_mode: strategy
public/js/phase538_execution_inspector_retry_strategies.js:35:        const res = await fetch("/api/delegate-task", {
public/js/delegation-wire.js:28:  var res = await fetch("/api/delegate-task", {
public/js/delegation-wire.js:40:    data = { error: "Non-JSON response from /api/delegate-task" };
public/js/phase457_restore_task_panels.js:6:    const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.js:9:    console.log("[retry-different][clean] click detected");
public/js/phase457_restore_task_panels.js:13:      console.warn("[retry-different][clean] no task row found");
public/js/phase457_restore_task_panels.js:20:      kind: "retry-strategy",
public/js/phase457_restore_task_panels.js:23:        retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.js:25:        retry_of_task_id: row.getAttribute("data-task-id"),
public/js/phase457_restore_task_panels.js:26:        retry_of_event_id: row.getAttribute("data-id"),
public/js/phase457_restore_task_panels.js:27:        retry_of_kind: "inspector-row",
public/js/phase457_restore_task_panels.js:33:      const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.js:40:      console.log("[retry-different][clean] queued:", data);
public/js/phase457_restore_task_panels.js:42:      console.error("[retry-different][clean] failed:", err);
public/js/phase538_execution_inspector_action_groups.js:27:      if (action === "requeue" || action === "retry") {
public/js/phase574_execution_inspector_success_feedback.js:23:    const retry = e.target.closest('[data-action="retry"]');
public/js/phase574_execution_inspector_success_feedback.js:24:    const requeue = e.target.closest('[data-action="requeue"]');
public/js/phase574_execution_inspector_success_feedback.js:26:    if (!retry && !requeue) return;
public/js/phase535_execution_inspector_requeue.js:9:    const btn = panel.querySelector('[data-action="requeue"]');
public/js/phase535_execution_inspector_requeue.js:24:        kind: "retry",
public/js/phase535_execution_inspector_requeue.js:26:          retry_of_task_id: taskId
public/js/phase535_execution_inspector_requeue.js:33:        const res = await fetch("/api/delegate-task", {
public/js/dashboard-delegation.js:143:        res = await safeFetch("/api/delegate-task", {
public/js/dashboard-delegation.js:169:        data = { error: "Non-JSON response from /api/delegate-task", raw: rawText || "" };
public/js/phase573_execution_inspector_debug.js:10:    const retry = e.target.closest('[data-action="retry"]');
public/js/phase573_execution_inspector_debug.js:11:    const requeue = e.target.closest('[data-action="requeue"]');
public/js/phase573_execution_inspector_debug.js:13:    if (retry) {
public/js/phase573_execution_inspector_debug.js:17:    if (requeue) {
public/js/task-delegation.js:2:    const delegateBtn = document.getElementById('delegate-task-btn');
public/js/task-delegation.js:11:            const response = await fetch('/api/delegate-task', {
public/js/phase16_sse_backoff.js:16: * - Only ONE retry timer
public/js/phase16_sse_backoff.js:49:    let retryTimer = null;
public/js/phase16_sse_backoff.js:79:      if (retryTimer) {
public/js/phase16_sse_backoff.js:80:        clearTimeout(retryTimer);
public/js/phase16_sse_backoff.js:81:        retryTimer = null;
public/js/phase16_sse_backoff.js:89:      emit("retry_scheduled", { reason, delayMs: ms });
public/js/phase16_sse_backoff.js:91:      retryTimer = setTimeout(() => {
public/js/phase16_sse_backoff.js:92:        retryTimer = null;
public/js/phase16_sse_backoff.js:93:        connect("retry");
public/js/phase16_sse_backoff.js:153:        // Close before retry so we don't stack sockets.
public/js/phase537_execution_inspector_retry.js:9:    const btn = panel.querySelector('[data-action="retry"]');
public/js/phase537_execution_inspector_retry.js:24:        kind: "retry",
public/js/phase537_execution_inspector_retry.js:26:          retry_of_task_id: taskId,
public/js/phase537_execution_inspector_retry.js:27:          retry_mode: "standard-retry"
public/js/phase537_execution_inspector_retry.js:32:        const res = await fetch("/api/delegate-task", {
public/js/phase534_execution_inspector_expand.js:84:        <span data-action="requeue" style="cursor:pointer; color:#facc15;">Requeue</span>
public/js/phase534_execution_inspector_expand.js:85:        <span data-action="retry" style="cursor:pointer; color:#60a5fa;">Retry</span>
public/js/task-events-sse-client.js:70:    const retryMode = p.retry_mode || "";
public/js/task-events-sse-client.js:73:    const isFresh = retryMode === "fresh-context" || executionMode === "rebuild_context";
public/js/task-events-sse-client.js:74:    const isRetry = retryMode || p.retry_of_task_id;
public/js/task-events-sse-client.js:94:      const res = await fetch("/api/delegate-task", {
public/js/task-events-sse-client.js:115:    container.querySelector('[data-action="requeue"]')?.addEventListener("click", (event) => {
public/js/task-events-sse-client.js:120:        kind: "retry",
public/js/task-events-sse-client.js:123:          retry_of_task_id: taskId,
public/js/task-events-sse-client.js:124:          retry_mode: "standard"
public/js/task-events-sse-client.js:130:    container.querySelector('[data-action="retry"]')?.addEventListener("click", (event) => {
public/js/task-events-sse-client.js:135:        kind: "retry",
public/js/task-events-sse-client.js:138:          retry_of_task_id: taskId,
public/js/task-events-sse-client.js:139:          retry_mode: "fresh-context"
public/js/task-events-sse-client.js:172:        <span data-action="requeue" style="color:#facc15; cursor:pointer;">Requeue</span>
public/js/task-events-sse-client.js:173:        <span data-action="retry" style="color:#60a5fa; cursor:pointer;">Retry</span>
public/js/telemetry/latency_metric.js:16:    "task.retrying",
public/js/telemetry/latency_metric.js:24:    "retrying",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:47:    if (/queue|pending|wait|hold|retry/.test(s)) return "#facc15";
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:209:            <span data-action="retry" style="cursor:pointer; color:#facc15;">Requeue</span>
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:210:            <span data-action="retry-different" style="cursor:pointer; color:#facc15;">Retry Differently</span>
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:271:        if (action === "retry") {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:277:            kind: "retry",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:280:              retry_of_task_id: selected.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:281:              retry_of_event_id: selected.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:282:              retry_of_kind: selected.kind
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:286:          fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:399:    const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:403:      console.warn("[retry-different] no selected item found");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:410:      kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:413:        retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:415:        retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:416:        retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:417:        retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:423:      const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:432:      console.log("[retry-different] queued:", data);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:434:      console.error("[retry-different] failed:", err);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:440:if (!window.__retryDifferentBound) {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:441:  window.__retryDifferentBound = true;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:444:    const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:448:      console.warn("[retry-different] no selected item");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:455:      kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:458:        retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:460:        retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:461:        retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:462:        retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:468:      const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:475:      console.log("[retry-different] queued:", data);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:477:      console.error("[retry-different] failed:", err);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:485:    if (window.__retryDifferentBoundFixed) return;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:486:    window.__retryDifferentBoundFixed = true;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:489:      const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:493:      console.log("[retry-different] click detected");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:496:        console.warn("[retry-different] no selected item");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:503:        kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:506:          retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:508:          retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:509:          retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:510:          retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:515:      fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:521:        .then(data => console.log("[retry-different] queued:", data))
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:522:        .catch(err => console.error("[retry-different] failed:", err));
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:536:    if (window.__retryDifferentBoundFixed) return;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:537:    window.__retryDifferentBoundFixed = true;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:540:      const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:543:      console.log("[retry-different] click detected");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:546:        console.warn("[retry-different] no selected item");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:553:        kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:556:          retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:558:          retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:559:          retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:560:          retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:565:      fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:571:        .then(data => console.log("[retry-different] queued:", data))
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:572:        .catch(err => console.error("[retry-different] failed:", err));
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:586:    const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:590:    console.log("[retry-different][override] click detected");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:593:      console.warn("[retry-different] no selected item");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:603:      kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:606:        retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:608:        retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:609:        retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:610:        retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:616:      const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:623:      console.log("[retry-different][override] queued:", data);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:625:      console.error("[retry-different][override] failed:", err);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:636:    const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:639:    console.log("[retry-different] click detected (delegated root)");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:642:      console.warn("[retry-different] no selected item");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:649:      kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:652:        retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:654:        retry_of_task_id: window.selectedItem.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:655:        retry_of_event_id: window.selectedItem.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:656:        retry_of_kind: window.selectedItem.kind,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:662:      const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:669:      console.log("[retry-different] queued:", data);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:671:      console.error("[retry-different] failed:", err);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:679:  const el = e.target.closest('[data-action="retry-different"]');
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:682:  console.log("[retry-different] click detected");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:687:    console.warn("[retry-different] no task row found");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:700:    kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:703:      retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:705:      retry_of_task_id: task.taskId,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:706:      retry_of_event_id: task.id,
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:707:      retry_of_kind: "inspector-row",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:712:  fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:718:    .then(data => console.log("[retry-different] queued:", data))
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:719:    .catch(err => console.error("[retry-different] failed:", err));
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:725:    document.querySelectorAll('[data-action="retry-different"]').forEach(el => {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:745:  document.querySelectorAll('[data-action="retry-different"]').forEach(el => {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:752:    if (el.__retryBound) return;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:753:    el.__retryBound = true;
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:758:      console.log("[retry-different] click (render-bound)");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:762:        console.warn("[retry-different] no task row found");
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:769:        kind: "retry-strategy",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:772:          retry_mode: "strategy_shift",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:774:          retry_of_task_id: row.getAttribute("data-task-id"),
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:775:          retry_of_event_id: row.getAttribute("data-id"),
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:776:          retry_of_kind: "inspector-row",
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:782:        const res = await fetch("/api/delegate-task", {
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:789:        console.log("[retry-different] queued:", data);
public/js/phase457_restore_task_panels.BROKEN_BACKUP.js:791:        console.error("[retry-different] failed:", err);
public/bundle.js:666:      "retrying"
public/bundle.js:1175:          res = await safeFetch("/api/delegate-task", {
public/bundle.js:1199:          data = { error: "Non-JSON response from /api/delegate-task", raw: rawText || "" };
public/bundle.js:1378:      if (/queue|pending|retry|wait|hold|sleep/.test(text)) return "waiting";
app/dev/page-ExecutionInspectorTest.tsx:17:            explanation: "All stages (DB → Worker → SSE) executed without error. No retry or intervention required."
server/db_wait_ready.mjs:8:  // retryable PG error codes we commonly see during startup
server/db_wait_ready.mjs:9:  const retryCodes = new Set([
server/db_wait_ready.mjs:27:        retryCodes.has(String(code)) ||
server/worker_retry_enforcer.js:4:  if (task.kind !== "retry") return task;
server/worker_retry_enforcer.js:6:  const mode = task.execution_mode || "standard_retry";
server/worker_retry_enforcer.js:15:    task.execution_mode = "standard_retry";
server/_lib/retry.mjs:1:export async function retry({ label, tries = 120, delayMs = 250, fn }) {
server/_lib/retry.mjs:5:      if (i > 1) console.log(`[retry] ${label}: attempt ${i}/${tries}`)
server/_lib/retry.mjs:11:      // retry only on common "db not ready" failure modes
server/utils/observability/structuredLogger.mjs:20:// structuredLog("retry.invoked", { mode: "standard", taskId: "123" });
server/retry_execution_router.js:2:  const strategy = task?.strategy || task?.meta?.retry_mode || "standard";
server/retry_execution_router.js:15:    execution_mode: "standard_retry",
server/integrations/execution_guidance_dev_probe.mjs:29:        explanation: 'Temporary failure, retry recommended',
server/integrations/execution_guidance_dev_probe.mjs:50:console.log("\n✅ Expect classifications: success / retryable / blocked");
server/db_bootstrap_tasks_retry_semantics.mjs:2: * Phase 27 — Tasks table retry + lease semantics (Postgres bootstrap)
server/execution_guidance_runner.mjs:54:          explanation: 'Temporary failure, retry recommended',
server/retry_contract.js:4:  if (body.kind !== "retry") {
server/retry_contract.js:8:  // Ensure deterministic retry strategy
server/retry_contract.js:22:  if (!body.meta || !body.meta.retry_of_task_id) {
server/orchestration/operator-commands.ts:10:  | { type: "task.retry"; id: string }
server/orchestration/operator-commands.ts:32: * - task retry <id>
server/orchestration/operator-commands.ts:75:  if (head === "task" && sub === "retry") {
server/orchestration/operator-commands.ts:77:    if (!id) return { ok: false, error: "task retry requires id" };
server/orchestration/operator-commands.ts:78:    return { ok: true, cmd: { type: "task.retry", id } };
server/orchestration/operator-commands.ts:123:    case "task.retry":
server/orchestration/operator-commands.ts:132:              payload: { op: "task.retry", id: cmd.id },
server/orchestration/scheduler.ts:16:  backoffBaseMs: number;             // base retry delay
server/orchestration/scheduler.ts:17:  backoffMaxMs: number;              // max retry delay
server/orchestration/scheduler.ts:33:  // attempt starts at 1 for first retry
server/orchestration/task-state-machine.ts:31:  | { type: "task.retry_wait"; ts: number; reason: string; nextAt: number }
server/orchestration/task-state-machine.ts:75:    case "task.retry_wait": {
server/api/tasks-mutations/delegate-taskspec.mjs:20: * POST /api/tasks-mutations/delegate-taskspec
server/worker/backoff.mjs:1:const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');
server/worker/execution_policy_runtime_logger.mjs:5:      is_retry: policy.is_retry,
server/worker/execution_policy_resolver.mjs:10:  const retryOfTaskId = payload.retry_of_task_id || null;
server/worker/execution_policy_resolver.mjs:13:    is_retry: Boolean(retryOfTaskId),
server/worker/execution_policy_resolver.mjs:14:    retry_of_task_id: retryOfTaskId,
server/worker/task_execution_interpreter.mjs:51:  if (meta?.retry_mode === "strategy_shift") {
server/worker/bootstrap_env_fix.mjs:1:const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');
server/worker/phase26_task_worker.mjs:3:require("../worker_retry_enforcer.js");
server/worker/phase27_markers.mjs:1:const { enforceWorkerRetryContract } = require('./worker_retry_enforcer');
server/execution_guidance_router.mjs:45:    combined.includes('retry') ||
server/execution_guidance_router.mjs:50:    return 'retryable';

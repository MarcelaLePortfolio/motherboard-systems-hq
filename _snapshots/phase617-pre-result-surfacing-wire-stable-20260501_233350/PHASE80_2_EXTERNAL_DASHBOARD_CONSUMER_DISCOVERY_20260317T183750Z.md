# Phase 80.2 — External Dashboard Consumer Discovery

Generated: 20260317T183750Z

## Possible app entrypoints outside dashboard/

./index.ts
./scripts/agents/matilda/index.ts
./snapshots/20251114-114707/index.ts
./snapshots/20251114-114821/index.ts

## Imports or references to dashboard/src/components


## Imports or references to dashboard/src/telemetry


## Direct references to QueueLatencyCard or computeQueueLatency

./dashboard/src/components/QueueLatencyCard.tsx:2:import { computeQueueLatency } from '../telemetry'
./dashboard/src/components/QueueLatencyCard.tsx:9:type QueueLatencyCardProps = {
./dashboard/src/components/QueueLatencyCard.tsx:30:export default function QueueLatencyCard({
./dashboard/src/components/QueueLatencyCard.tsx:33:}: QueueLatencyCardProps) {
./dashboard/src/components/QueueLatencyCard.tsx:36:    return computeQueueLatency(tasks)
./dashboard/src/components/index.ts:1:export { default as QueueLatencyCard } from './QueueLatencyCard'
./dashboard/src/telemetry/queueLatency.ts:28:export function computeQueueLatency(tasks: any[]): QueueLatencyStats {
./dashboard/src/telemetry/index.ts:1:export { computeQueueLatency } from './queueLatency'

## Existing telemetry/task dashboard candidates outside dashboard/

./public_broken_rollback_1762824556/dashboard-reflections.js:1:console.log("<0001fe10> dashboard-reflections.js initialized");
./public_broken_rollback_1762824556/dashboard-ops.js:1:console.log("<0001fe20> dashboard-ops.js initialized");
./public_broken_rollback_1762824556/agent-status-row.js:8:  let dashboardLine = null;
./public_broken_rollback_1762824556/agent-status-row.js:11:      dashboardLine = el;
./public_broken_rollback_1762824556/agent-status-row.js:41:  if (dashboardLine && dashboardLine.parentNode) {
./public_broken_rollback_1762824556/agent-status-row.js:42:    dashboardLine.parentNode.insertBefore(stabilityRow, dashboardLine);
./public_broken_rollback_1762824556/agent-status-row.js:43:    dashboardLine.parentNode.insertBefore(agentRow, dashboardLine.nextSibling);
./tools/log-to-ticker.js:5:const tickerLogPath = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./archive/legacy_cade_helpers/cade_reasoning.js:4:const TICKER_LOG = path.resolve('ui/dashboard/ticker-events.log');
./reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./dist/scripts/demo/run-demo-sequence.js:25:        console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./dist/scripts/demo/run-demo-playback.js:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./dist/scripts/demo/run-demo-playback.js:30:        console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./dist/scripts/demo/reflection-pacer.js:2:// Ensures dashboard reflections appear smoothly, one per second.
./dist/scripts/demo/verify-dashboard-sync.js:19:    console.log("🧠 Verifying live dashboard sync endpoints...");
./dist/scripts/demo/verify-dashboard-sync.js:22:    console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./dist/scripts/demo/run-create-atlas.js:15:    console.log("Use dashboard to verify task appearance in Recent Tasks panel.");
./dist/scripts/sse/reflections-sse-server.js:10:    "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./dist/scripts/reset-roundtrip.js:22:        console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./dist/scripts/sequences/atlas-build-sequence.js:29:    await logReflection("Effie", "Verifying SQLite telemetry + dashboard integration.");
./dist/scripts/sequences/demo-cinematic-sequence.js:15:logReflection("Effie aligning dashboards with live reflections...", 4000);
./dist/scripts/sequences/demo-cinematic-sequence.js:17:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./dist/scripts/_archive/matilda_delegate.js:13:    const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./dist/scripts/_local/dev-server.js:8:app.get("/", (req, res) => res.redirect("/dashboard.html"));
./dist/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:12:    // ✅ Event emitter for dashboard ticker
./dist/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:13:    fs.appendFileSync("ui/dashboard/ticker-events.log", { "timestamp": "${Math.floor(Date.now()/1000)}", "agent": "matilda", "event": "auto-deploy" });
./dist/scripts/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./snapshots/20251114-114821/public/dashboard-logs.v3.js:2:  console.log("✅ dashboard-logs.v3.js running");
./snapshots/20251114-114821/public/js/agent-interaction-animation.js:61:    // Toggle button for dashboard control
./snapshots/20251114-114821/public/dashboard-logs.js:2:console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./snapshots/20251114-114821/public/dashboard-logs.js:5:  console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./snapshots/20251114-114821/public/dashboard.js:2:  console.log("📋 DOM fully loaded — dashboard.js executing safely");
./snapshots/20251114-114821/scripts/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./snapshots/20251114-114821/scripts/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./snapshots/20251114-114821/scripts/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./snapshots/20251114-114821/scripts/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./snapshots/20251114-114821/scripts/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./snapshots/20251114-114821/scripts/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./snapshots/20251114-114821/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./snapshots/20251114-114821/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./snapshots/20251114-114821/scripts/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./snapshots/20251114-114821/server.ts:22:  res.sendFile(path.join(publicPath, "dashboard.html"));
./snapshots/20251114-114707/public/dashboard-logs.v3.js:2:  console.log("✅ dashboard-logs.v3.js running");
./snapshots/20251114-114707/public/js/agent-interaction-animation.js:61:    // Toggle button for dashboard control
./snapshots/20251114-114707/public/dashboard-logs.js:2:console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./snapshots/20251114-114707/public/dashboard-logs.js:5:  console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./snapshots/20251114-114707/public/dashboard.js:2:  console.log("📋 DOM fully loaded — dashboard.js executing safely");
./snapshots/20251114-114707/scripts/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./snapshots/20251114-114707/scripts/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./snapshots/20251114-114707/scripts/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./snapshots/20251114-114707/scripts/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./snapshots/20251114-114707/scripts/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./snapshots/20251114-114707/scripts/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./snapshots/20251114-114707/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./snapshots/20251114-114707/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./snapshots/20251114-114707/scripts/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./snapshots/20251114-114707/server.ts:16:  res.sendFile(path.join(publicPath, "dashboard.html"));
./seed_agents.js:7:  database: process.env.POSTGRES_DB || 'dashboard_db',
./server/orchestration/operator-commands.ts:4:  | { type: "mode.set"; mode: PolicyContext["operatorMode"] }
./server/orchestration/operator-commands.ts:13:const MODES: PolicyContext["operatorMode"][] = ["NORMAL", "SAFE", "FOCUS", "PAUSE", "DRAIN", "DEBUG"];
./server/orchestration/operator-commands.ts:15:function isMode(x: string): x is PolicyContext["operatorMode"] {
./server/orchestration/operator-commands.ts:24: * Minimal operator command parser (Phase 17.5):
./server/orchestration/operator-commands.ts:117:              source: "operator",
./server/orchestration/operator-commands.ts:131:              source: "operator",
./server/orchestration/operator-commands.ts:145:              source: "operator",
./server/orchestration/scheduler.test.ts:23:const ctxNormal: PolicyContext = { now: 100, operatorMode: "NORMAL", intent: null };
./server/orchestration/scheduler.test.ts:24:const ctxPause: PolicyContext = { now: 100, operatorMode: "PAUSE", intent: null };
./server/orchestration/router.ts:30: * - If operatorMode is PAUSE or DRAIN, do not route (scheduler will handle later; return ok:false).
./server/orchestration/router.ts:37:  if (ctx.operatorMode === "PAUSE" || ctx.operatorMode === "DRAIN") {
./server/orchestration/router.ts:38:    return { ok: false, reason: `operatorMode=${ctx.operatorMode} blocks routing` };
./server/orchestration/scheduler.ts:49:  if (ctx.operatorMode === "PAUSE") return { ok: true, eligible: false, reason: "operatorMode=PAUSE" };
./server/orchestration/scheduler.ts:50:  if (ctx.operatorMode === "DRAIN") return { ok: true, eligible: false, reason: "operatorMode=DRAIN (no new starts)" };
./server/orchestration/task-state-machine.ts:34:  | { type: "task.cancel"; ts: number; by: "operator" | "policy"; reason?: string };
./server/orchestration/policy-pipeline.ts:21:        next.operatorMode = d.mode;
./server/orchestration/router.test.ts:6:const ctxNormal: PolicyContext = { now: 1, operatorMode: "NORMAL", intent: null };
./server/orchestration/router.test.ts:7:const ctxPause: PolicyContext = { now: 1, operatorMode: "PAUSE", intent: null };
./server/orchestration/operator-commands.test.ts:3:import { parseOperatorCommand, commandToDecisions } from "./operator-commands";
./server/orchestration/policy.ts:7:  operatorMode: "NORMAL" | "SAFE" | "FOCUS" | "PAUSE" | "DRAIN" | "DEBUG";
./server/orchestration/policy.ts:14:  | { kind: "set_mode"; mode: PolicyContext["operatorMode"] }
./scripts_backup/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./scripts_backup/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./scripts_backup/demo/run-create-atlas.ts:22:  console.log("Use dashboard to verify task appearance in Recent Tasks panel.");
./scripts_backup/demo/reflection-pacer.js:2:// Ensures dashboard reflections appear smoothly, one per second.
./scripts_backup/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./scripts_backup/demo/run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./scripts_backup/demo/run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./scripts_backup/sse/reflections-sse-server.ts:16:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./scripts_backup/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./scripts_backup/sequences/demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./scripts_backup/sequences/demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./scripts_backup/scripts/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./scripts_backup/scripts/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./scripts_backup/scripts/demo/run-create-atlas.ts:22:  console.log("Use dashboard to verify task appearance in Recent Tasks panel.");
./scripts_backup/scripts/demo/reflection-pacer.js:2:// Ensures dashboard reflections appear smoothly, one per second.
./scripts_backup/scripts/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./scripts_backup/scripts/demo/run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./scripts_backup/scripts/demo/run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./scripts_backup/scripts/sse/reflections-sse-server.ts:16:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./scripts_backup/scripts/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./scripts_backup/scripts/sequences/demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./scripts_backup/scripts/sequences/demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./scripts_backup/scripts/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./scripts_backup/scripts/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./scripts_backup/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./scripts_backup/scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./scripts_backup/scripts/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./scripts_backup/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./scripts_backup/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./scripts_backup/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./scripts_backup/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./scripts_backup/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./matilda-chat-stub.js:5:* This is used directly by server.mjs so the dashboard/container can
./exports/dashboard_phase6.8/js/agent-interaction-animation.js:61:    // Toggle button for dashboard control
./dashboard/src/components/QueueLatencyCard.tsx:2:import { computeQueueLatency } from '../telemetry'
./dashboard/src/telemetry/queueLatency.ts:9:- Pure derived telemetry
./dashboard/src/operator/runbooks/operatorRunbookResolver.ts:1:import { RUNBOOK_CATALOG } from "./operatorRunbookCatalog";
./dashboard/src/operator/runbooks/operatorRunbookResolver.ts:2:import type { Runbook } from "./operatorRunbookTypes";
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:1:import type { Runbook } from "./operatorRunbookTypes";
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:3:export function formatRunbook(runbook: Runbook): string {
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:4:  const steps = runbook.steps
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:10:    `Runbook: ${runbook.title}`,
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:11:    `Risk: ${runbook.risk}`,
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:12:    `State: ${runbook.state}`,
./dashboard/src/operator/runbooks/operatorRunbookFormatter.ts:17:    `SAFE TO CONTINUE: ${runbook.continueSafe ? "YES" : "NO"}`
./dashboard/src/operator/runbooks/operatorRunbookCatalog.ts:1:import type { Runbook } from "./operatorRunbookTypes";
./dashboard/src/operator/runbooks/operatorRunbookCatalog.ts:53:    { id: "monitor", description: "Monitor telemetry" },
./public/dashboard-logs.v3.js:2:  console.log("✅ dashboard-logs.v3.js running");
./public/js/sse-tasks-singleton.js:2: * Phase 13.5 — Tasks SSE Hard Singleton + Close-Guard + Debug (dashboard-only)
./public/js/heartbeat-stale-indicator.js:5: * - Adds a badge to the top-right corner of the dashboard.
./public/js/ops-pill-state.js:2:// Phase 11: simple dashboard OPS pill driven by lastOpsHeartbeat.
./public/js/ops-pill-state.js:3:// - Creates #ops-dashboard-pill on /dashboard if missing.
./public/js/ops-pill-state.js:9:  if (window.location.pathname !== "/dashboard") return;
./public/js/ops-pill-state.js:12:  var PILL_ID = "ops-dashboard-pill";
./public/js/ops-pill-state.js:18:    // Create the dashboard pill near the top of the body
./public/js/phase23_matilda_chat_hook.js:3:  console.log("[diag] phase23_matilda_chat_hook disabled for dashboard stability isolation");
./public/js/phase13_5_operator_ux.js:3:  console.log("[diag] phase13_5_operator_ux disabled for dashboard stability isolation");
./public/js/delegation-wire.js:1:// Phase 11 v11.10 – minimal dashboard Task Delegation wiring
./public/js/task-activity-graph.js:8: * Exported so dashboard-graph-loader.js can import it.
./public/js/phase16_reflections_ui_consumer.js:3:  console.log("[diag] phase16_reflections_ui_consumer disabled for dashboard stability isolation");
./public/js/telemetry_queue_depth_reducer.js:3:Deterministic telemetry reducer
./public/js/telemetry_queue_depth_reducer.js:53:  if (window.telemetryBus && window.telemetryBus.subscribe) {
./public/js/telemetry_queue_depth_reducer.js:54:    window.telemetryBus.subscribe("task-events", processEvent);
./public/js/telemetry_queue_depth_reducer.js:57:  // Read-only exposure for metrics layer
./public/js/dashboard-bundle-entry.js:3:// Phase 11 – Unified dashboard bundle entrypoint
./public/js/dashboard-bundle-entry.js:5:// Core dashboard status + tiles
./public/js/dashboard-bundle-entry.js:6:import "./dashboard-status.js";
./public/js/dashboard-bundle-entry.js:16:import "./dashboard-broadcast.js";
./public/js/dashboard-bundle-entry.js:21:// import "./dashboard-tasks-widget.js";
./public/js/dashboard-bundle-entry.js:25:import "./dashboard-delegation.js";
./public/js/dashboard-bundle-entry.js:27:// TEMP: dashboard graph disabled until canvas is present on all pages
./public/js/dashboard-bundle-entry.js:28:// import "./dashboard-graph.js";
./public/js/dashboard-bundle-entry.js:34:// Phase 62B/65C: telemetry metric ownership bootstrap
./public/js/dashboard-bundle-entry.js:35:import "./telemetry/phase65b_metric_bootstrap.js";
./public/js/dashboard-delegation.js:2:  console.log("[dashboard-delegation] module loaded");
./public/js/dashboard-delegation.js:11:    console.log("[dashboard-delegation] detected fetch type:", t);
./public/js/dashboard-delegation.js:13:      console.error("[dashboard-delegation] fetch is not a function; value:", f);
./public/js/dashboard-delegation.js:54:      "Awaiting operator input.<br>Results from delegation requests will appear here."
./public/js/dashboard-delegation.js:108:      console.warn("[dashboard-delegation] delegation input not found at click time");
./public/js/dashboard-delegation.js:115:      console.warn("[dashboard-delegation] empty delegation input; skipping");
./public/js/dashboard-delegation.js:120:    console.log("[dashboard-delegation] sending delegation:", value);
./public/js/dashboard-delegation.js:123:      console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid");
./public/js/dashboard-delegation.js:152:        console.error("[dashboard-delegation] fetch threw before response:", err);
./public/js/dashboard-delegation.js:156:      console.log("[dashboard-delegation] fetch returned:", {
./public/js/dashboard-delegation.js:168:        console.error("[dashboard-delegation] error parsing JSON response:", err);
./public/js/dashboard-delegation.js:172:      console.log("[dashboard-delegation] delegation response:", data);
./public/js/dashboard-delegation.js:199:      console.warn("[dashboard-delegation] delegation button or input not found in init");
./public/js/dashboard-delegation.js:206:      console.log("[dashboard-delegation] Task Delegation wiring already active");
./public/js/dashboard-delegation.js:220:    console.log("[dashboard-delegation] Task Delegation wiring active");
./public/js/phase16_sse_owner_ops_reflections.js:3:  console.log("[diag] phase16_sse_owner_ops_reflections disabled for dashboard stability isolation");
./public/js/ops-status-widget.js:6:  var existing = document.getElementById("ops-dashboard-pill");
./public/js/ops-status-widget.js:12:  pill.id = "ops-dashboard-pill";
./public/js/task-activity.js:13:                label: 'Tasks Completed',
./public/js/telemetry_failed_tasks_reducer.js:3:Deterministic telemetry reducer
./public/js/telemetry_failed_tasks_reducer.js:47:  if (window.telemetryBus && window.telemetryBus.subscribe) {
./public/js/telemetry_failed_tasks_reducer.js:48:    window.telemetryBus.subscribe("task-events", processEvent);
./public/js/dashboard-ops-reflections-ui.js:3:  console.log("[diag] dashboard-ops-reflections-ui disabled for dashboard stability isolation");
./public/js/agent-status-row.js:4:// dense operator-console row appearance with role emojis.
./public/js/agent-status-row.js:370:  const successNode = null; // Phase 62B: success writer neutralized; telemetry module remains sole writer
./public/js/agent-status-row.js:487:      // Phase 65B.2: metric-tasks ownership transferred to telemetry reducer
./public/js/agent-status-row.js:491:      // Phase 65C: metric-success ownership transferred to telemetry reducer
./public/js/agent-status-row.js:495:      // Phase 65C: metric-latency ownership transferred to telemetry reducer
./public/js/phase31_6_seed_task_button.js:52:        msg: "seeded from dashboard button",
./public/js/phase31_6_seed_task_button.js:57:        actor: "dashboard",
./public/js/phase16_sse_status_indicator.js:3:  console.log("[diag] phase16_sse_status_indicator disabled for dashboard stability isolation");
./public/js/matilda-chat-console.js:103:        input.value = "Quick systems check from dashboard Phase 11.4.";
./public/js/telemetry/success_rate_metric.js:3:Success Rate Metric
./public/js/telemetry/phase65b_metric_ownership_guard.js:5:Ensure metric-tasks is owned only by telemetry reducer.
./public/js/telemetry/phase65b_metric_bootstrap.js:12:    load("/js/telemetry/phase65b_metric_ownership_guard.js");
./public/js/telemetry/phase65b_metric_bootstrap.js:13:    load("/js/telemetry/running_tasks_metric.js");
./public/js/telemetry/phase65b_metric_bootstrap.js:14:    load("/js/telemetry/success_rate_metric.js");
./public/js/telemetry/phase65b_metric_bootstrap.js:15:    load("/js/telemetry/latency_metric.js");
./public/js/phase23_matilda_task_events_bridge.js:3:  console.log("[diag] phase23_matilda_task_events_bridge disabled for dashboard stability isolation");
./public/js/reflections-sse-dashboard.js:1:// Phase 11 – Reflections SSE wiring for dashboard bundle (temporarily disabled)
./public/js/reflections-sse-dashboard.js:11:// is running and reachable from the dashboard bundle.
./public/js/phase23_matilda_delegate_taskspec.js:3:  console.log("[diag] phase23_matilda_delegate_taskspec disabled for dashboard stability isolation");
./public/dashboard-logs.js:2:console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./public/dashboard-logs.js:5:  console.log("📋 DOM fully loaded — dashboard-logs.js executing safely");
./public/bundle.js:144:  // public/js/dashboard-status.js
./public/bundle.js:823:  // public/js/dashboard-broadcast.js
./public/bundle.js:875:    var existing = document.getElementById("ops-dashboard-pill");
./public/bundle.js:879:    pill.id = "ops-dashboard-pill";
./public/bundle.js:933:    if (window.location.pathname !== "/dashboard") return;
./public/bundle.js:935:    var PILL_ID = "ops-dashboard-pill";
./public/bundle.js:1058:          input.value = "Quick systems check from dashboard Phase 11.4.";
./public/bundle.js:1073:  // public/js/dashboard-delegation.js
./public/bundle.js:1075:    console.log("[dashboard-delegation] module loaded");
./public/bundle.js:1082:      console.log("[dashboard-delegation] detected fetch type:", t);
./public/bundle.js:1084:        console.error("[dashboard-delegation] fetch is not a function; value:", f);
./public/bundle.js:1111:        "Awaiting operator input.<br>Results from delegation requests will appear here."
./public/bundle.js:1146:        console.warn("[dashboard-delegation] delegation input not found at click time");
./public/bundle.js:1152:        console.warn("[dashboard-delegation] empty delegation input; skipping");
./public/bundle.js:1156:      console.log("[dashboard-delegation] sending delegation:", value);
./public/bundle.js:1159:        console.error("[dashboard-delegation] aborting delegation because fetch is unavailable or invalid");
./public/bundle.js:1184:          console.error("[dashboard-delegation] fetch threw before response:", err);
./public/bundle.js:1187:        console.log("[dashboard-delegation] fetch returned:", {
./public/bundle.js:1198:          console.error("[dashboard-delegation] error parsing JSON response:", err);
./public/bundle.js:1201:        console.log("[dashboard-delegation] delegation response:", data);
./public/bundle.js:1225:        console.warn("[dashboard-delegation] delegation button or input not found in init");
./public/bundle.js:1230:        console.log("[dashboard-delegation] Task Delegation wiring already active");
./public/bundle.js:1241:      console.log("[dashboard-delegation] Task Delegation wiring active");
./public/bundle.js:1775:  // public/js/telemetry/phase65b_metric_bootstrap.js
./public/bundle.js:1785:      load("/js/telemetry/phase65b_metric_ownership_guard.js");
./public/bundle.js:1786:      load("/js/telemetry/running_tasks_metric.js");
./public/bundle.js:1787:      load("/js/telemetry/success_rate_metric.js");
./public/bundle.js:1788:      load("/js/telemetry/latency_metric.js");
./public/bundle.js:1797:  // public/js/dashboard-bundle-entry.js
./public/scripts/dashboard-reflections.js:1:console.log("<0001fe10> dashboard-reflections.js initialized");
./public/scripts/dashboard-ops.js:1:console.log("<0001fe20> dashboard-ops.js initialized");
./public/scripts/agent-status-row.js:8:  const byId = document.getElementById("dashboard-build-banner");
./public/scripts/agent-status-row.js:19:  console.warn("⚠️ Could not find dashboard-build-banner anchor — appending to body instead");
./public/dashboard.js:6:The dashboard "Recent Tasks" panel is driven by task-events (SSE) + mb.task.event bridge.
./public/bundle-core.js:17:  // public/js/dashboard-status.js
./public/bundle-core.js:31:      console.warn("dashboard-status.js: Core status elements not found in DOM.");
./public/bundle-core.js:92:      console.error("dashboard-status.js: Failed to open OPS SSE connection:", err);
./public/bundle-core.js:154:      console.warn("dashboard-status.js: OPS SSE error:", err);
./public/bundle-core.js:170:      console.error("dashboard-status.js: Failed to open Reflections SSE connection:", err);
./public/bundle-core.js:191:      console.warn("dashboard-status.js: Reflections SSE error:", err);
./public/bundle-core.js:1956:      const metrics = ctx2.measureText(line);
./public/bundle-core.js:1957:      const left = x - metrics.actualBoundingBoxLeft;
./public/bundle-core.js:1958:      const right = x + metrics.actualBoundingBoxRight;
./public/bundle-core.js:1959:      const top = y - metrics.actualBoundingBoxAscent;
./public/bundle-core.js:1960:      const bottom = y + metrics.actualBoundingBoxDescent;
./public/bundle-core.js:2146:      * A trap for the delete operator.
./public/bundle-core.js:2174:      * A trap for the in operator.
./public/bundle-core.js:2209:      * A trap for the delete operator.
./public/bundle-core.js:2239:      * A trap for the in operator.
./public/bundle-core.js:14717:  // public/js/dashboard-graph-loader.js
./public/bundle-core.js:14736:  // public/js/dashboard-graph.js
./public/bundle-core.js:14778:  // public/js/dashboard-broadcast.js
./public/bundle-core.js:14795:  // public/scripts/dashboard-reflections.js
./public/bundle-core.js:14796:  console.log("<0001fe10> dashboard-reflections.js initialized");
./public/bundle-core.js:14812:  // public/scripts/dashboard-ops.js
./public/bundle-core.js:14813:  console.log("<0001fe20> dashboard-ops.js initialized");
./public/bundle-core.js:14828:  // public/scripts/dashboard-chat.js
./scripts/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./scripts/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./scripts/demo/run-create-atlas.ts:22:  console.log("Use dashboard to verify task appearance in Recent Tasks panel.");
./scripts/demo/reflection-pacer.js:2:// Ensures dashboard reflections appear smoothly, one per second.
./scripts/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./scripts/demo/run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./scripts/demo/run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./scripts/sse/reflections-sse-server.ts:12:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./scripts/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./scripts/dashboard-reflections.js:1:console.log("<0001fe10> dashboard-reflections.js initialized");
./scripts/dashboard-ops.js:1:console.log("<0001fe20> dashboard-ops.js initialized");
./scripts/sequences/demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./scripts/sequences/demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./scripts/sequences/atlas-build-sequence.ts:36:  await logReflection("Effie", "Verifying SQLite telemetry + dashboard integration.");
./scripts/operator-runbook-smoke.ts:1:import { resolveOperatorRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookResolver";
./scripts/operator-runbook-smoke.ts:2:import { formatRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookFormatter";
./scripts/operator-runbook-smoke.ts:40:  const runbook = resolveOperatorRunbook(scenario.input);
./scripts/operator-runbook-smoke.ts:44:  console.log(formatRunbook(runbook));
./scripts/agent-status-row.js:8:  let dashboardLine = null;
./scripts/agent-status-row.js:11:      dashboardLine = el;
./scripts/agent-status-row.js:41:  if (dashboardLine && dashboardLine.parentNode) {
./scripts/agent-status-row.js:42:    dashboardLine.parentNode.insertBefore(stabilityRow, dashboardLine);
./scripts/agent-status-row.js:43:    dashboardLine.parentNode.insertBefore(agentRow, dashboardLine.nextSibling);
./scripts/operator-runbook-assert.ts:1:import { resolveOperatorRunbook } from "../dashboard/src/operator/runbooks/operatorRunbookResolver";
./scripts/operator-runbook-assert.ts:84:  const runbook = resolveOperatorRunbook(scenario.input);
./scripts/operator-runbook-assert.ts:86:  assertEqual(`${scenario.name} id`, runbook.id, scenario.expected.id);
./scripts/operator-runbook-assert.ts:87:  assertEqual(`${scenario.name} continueSafe`, runbook.continueSafe, scenario.expected.continueSafe);
./scripts/operator-runbook-assert.ts:88:  assertEqual(`${scenario.name} risk`, runbook.risk, scenario.expected.risk);
./scripts/operator-runbook-assert.ts:89:  assertEqual(`${scenario.name} state`, runbook.state, scenario.expected.state);
./scripts/operator-runbook-assert.ts:91:  console.log(`PASS ${scenario.name} -> ${runbook.id}`);
./scripts/build-dashboard-bundle.js:3:const entryFile = "public/js/dashboard-bundle-entry.js";
./scripts/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./scripts/_local/phase74_operator_workflow_helpers_smoke.ts:6:import { getOperatorWorkflowSuggestions } from "./phase74_operator_workflow_helpers";
./scripts/_local/phase76_operator_playbooks.ts:4:Defines deterministic operator playbooks.
./scripts/_local/phase76_operator_playbooks.ts:11:NO telemetry mutation
./scripts/_local/phase76_operator_playbooks.ts:15:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase77_signal_severity_model.ts:4:Deterministic severity scoring for operator signals.
./scripts/_local/phase77_signal_severity_model.ts:10:NO telemetry mutation
./scripts/_local/phase77_signal_severity_model.ts:15:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase77_signal_severity_model.ts:26:  telemetryGap: SeverityLevel;
./scripts/_local/phase77_signal_severity_model.ts:51:  const telemetryGap = severityFromBoolean(signals.telemetryGap);
./scripts/_local/phase77_signal_severity_model.ts:59:    telemetryGap,
./scripts/_local/phase77_signal_severity_model.ts:68:    telemetryGap,
./scripts/_local/phase75_operator_ranked_helpers.ts:14:import { getOperatorWorkflowSuggestions } from "./phase74_operator_workflow_helpers";
./scripts/_local/phase75_operator_ranked_helpers.ts:15:import { scoreHelperAction } from "./phase75_operator_helper_priority";
./scripts/_local/phase75_operator_ranked_helpers.ts:16:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase73_operator_safety_gates_smoke.ts:6:import { evaluateOperatorSafetyGate } from "./phase73_operator_safety_gates";
./scripts/_local/phase73_operator_safety_gates_smoke.ts:36:    { telemetryGap: true },
./scripts/_local/phase76_playbook_selection_smoke.ts:6:import { getIntegratedPlaybookSelection } from "./phase76_operator_playbook_selection";
./scripts/_local/phase77_multi_signal_weighting.ts:4:Deterministic weighting model for blended operator signals.
./scripts/_local/phase77_multi_signal_weighting.ts:10:NO telemetry mutation
./scripts/_local/phase77_multi_signal_weighting.ts:15:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase77_multi_signal_weighting.ts:20:  telemetryGapWeight: number;
./scripts/_local/phase77_multi_signal_weighting.ts:28:    | "telemetryGap"
./scripts/_local/phase77_multi_signal_weighting.ts:44:  const telemetryGapWeight = boolWeight(signals.telemetryGap, 70);
./scripts/_local/phase77_multi_signal_weighting.ts:52:    ["telemetryGap", telemetryGapWeight],
./scripts/_local/phase77_multi_signal_weighting.ts:61:    telemetryGapWeight +
./scripts/_local/phase77_multi_signal_weighting.ts:74:    telemetryGapWeight,
./scripts/_local/phase75_operator_helper_priority.ts:11:NO telemetry mutation
./scripts/_local/phase75_operator_helper_priority.ts:14:import type { OperatorActionType } from "./phase73_operator_safety_gates";
./scripts/_local/phase72_operator_guidance_schema.ts:3:Canonical read-only output model for operator guidance.
./scripts/_local/phase72_operator_guidance_schema.ts:14:  | "telemetry_gap"
./scripts/_local/phase77_adaptation_guardrails.ts:6:import type { PlaybookStep } from "./phase76_operator_playbooks";
./scripts/_local/phase76_operator_playbook_selection.ts:10:NO telemetry mutation
./scripts/_local/phase76_operator_playbook_selection.ts:15:import { getOperatorPlaybook } from "./phase76_operator_playbooks";
./scripts/_local/phase76_operator_playbook_selection.ts:16:import { getRankedWorkflowSuggestions } from "./phase75_operator_ranked_helpers";
./scripts/_local/phase76_operator_playbook_selection.ts:17:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase76_operator_playbook_selection.ts:18:import type { PlaybookStep } from "./phase76_operator_playbooks";
./scripts/_local/phase75_operator_helper_priority_smoke.ts:5:import { scoreHelperAction } from "./phase75_operator_helper_priority";
./scripts/_local/phase72_operator_guidance_command.ts:3:Read-only operator guidance command.
./scripts/_local/phase72_operator_guidance_command.ts:7:- NO telemetry mutation
./scripts/_local/phase72_operator_guidance_command.ts:17:} from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase72_operator_guidance_command.ts:18:import { classifyOperatorSafety } from "./phase72_operator_safety_classifier";
./scripts/_local/phase72_operator_guidance_interpreter.ts:7:- NO telemetry mutation
./scripts/_local/phase72_operator_guidance_interpreter.ts:28:  telemetryGap?: boolean;
./scripts/_local/phase72_operator_guidance_interpreter.ts:52:    signals.telemetryGap
./scripts/_local/phase68_event_schema_validator.ts:56:    throw new Error("Input must be a JSON array of telemetry events.");
./scripts/_local/phase68_event_schema_validator.ts:61:      throw new Error("Each telemetry event must be a JSON object.");
./scripts/_local/phase72_operator_safety_classifier.ts:15:} from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase72_operator_safety_classifier.ts:55:  if (signals.telemetryGap) {
./scripts/_local/phase72_operator_safety_classifier.ts:56:    warnings.push("telemetry_gap");
./scripts/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./scripts/_local/phase77_signal_severity_model_smoke.ts:34:    telemetryGap: true,
./scripts/_local/phase77_signal_severity_model_smoke.ts:38:  assert(result.telemetryGap === "HIGH", "Expected HIGH telemetry gap severity");
./scripts/_local/phase72_operator_guidance_smoke.ts:3:Verifies operator guidance produces stable outputs.
./scripts/_local/phase72_operator_guidance_smoke.ts:6:import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";
./scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./scripts/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./scripts/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./scripts/_local/phase73_operator_safety_gates.ts:7:- NO telemetry mutation
./scripts/_local/phase73_operator_safety_gates.ts:13:import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";
./scripts/_local/phase73_operator_safety_gates.ts:14:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase74_operator_workflow_helpers.ts:13:import { runOperatorGuidanceCommand } from "./phase72_operator_guidance_command";
./scripts/_local/phase74_operator_workflow_helpers.ts:14:import { evaluateOperatorSafetyGate } from "./phase73_operator_safety_gates";
./scripts/_local/phase74_operator_workflow_helpers.ts:15:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase74_operator_workflow_helpers.ts:16:import type { OperatorActionType } from "./phase73_operator_safety_gates";
./scripts/_local/phase75_ranked_helpers_smoke.ts:5:import { getRankedWorkflowSuggestions } from "./phase75_operator_ranked_helpers";
./scripts/_local/phase76_playbook_smoke.ts:6:import { getOperatorPlaybook } from "./phase76_operator_playbooks";
./scripts/_local/phase77_adaptive_playbook_ordering.ts:10:NO telemetry mutation
./scripts/_local/phase77_adaptive_playbook_ordering.ts:15:import { getOperatorPlaybook } from "./phase76_operator_playbooks";
./scripts/_local/phase77_adaptive_playbook_ordering.ts:17:import type { OperatorSignals } from "./phase72_operator_guidance_interpreter";
./scripts/_local/phase77_adaptive_playbook_ordering.ts:18:import type { PlaybookStep } from "./phase76_operator_playbooks";
./run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./eslint.config.js:20:      'ui/dashboard/public/**',
./eslint.config.js:21:      'ui/dashboard/serve-root/**'
./dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./ts-backup/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./ts-backup/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./ts-backup/demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./ts-backup/demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./ts-backup/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./ts-backup/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./ts-backup/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./ts-backup/run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./ts-backup/run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./ts-backup/server.ts:10:  res.redirect("/dashboard.html");
./ts-backup/reflections-sse-server.ts:12:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./server.ts:22:  res.sendFile(path.join(publicPath, "dashboard.html"));
./scripts_backup_2/demo/verify-dashboard-sync.ts:19:  console.log("🧠 Verifying live dashboard sync endpoints...");
./scripts_backup_2/demo/verify-dashboard-sync.ts:22:  console.log("✅ Verification sequence complete. Check dashboard for Recent Tasks & Logs updates.");
./scripts_backup_2/demo/run-create-atlas.ts:22:  console.log("Use dashboard to verify task appearance in Recent Tasks panel.");
./scripts_backup_2/demo/reflection-pacer.js:2:// Ensures dashboard reflections appear smoothly, one per second.
./scripts_backup_2/demo/run-demo-sequence.ts:33:    console.log("💡 Open http://localhost:3001/dashboard.html to view live broadcast.");
./scripts_backup_2/demo/run-demo-playback.ts:2:// Simulates cinematic agent delegation, reflection flow, and synchronized dashboard updates
./scripts_backup_2/demo/run-demo-playback.ts:39:    console.log("🎉 Demo playback complete — dashboard should now display synchronized cinematic flow.");
./scripts_backup_2/sse/reflections-sse-server.ts:16:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",
./scripts_backup_2/reset-roundtrip.ts:27:    console.log("⚙️ Reset complete. Ready for dashboard auto-refresh.");
./scripts_backup_2/sequences/demo-cinematic-sequence.ts:18:logReflection("Effie aligning dashboards with live reflections...", 4000);
./scripts_backup_2/sequences/demo-cinematic-sequence.ts:20:logReflection("OPS stream synchronized — live metrics at :3201", 7000);
./scripts_backup_2/_archive/matilda_delegate.js:17:  const tickerLog = path.join(process.cwd(), 'ui/dashboard/ticker-events.log');
./scripts_backup_2/_local/dev-server.ts:14:const UI_DIR = join(process.cwd(), "ui", "dashboard");
./scripts_backup_2/_local/agent-runtime/matilda-auto-deploy-patch.js:15:  // ✅ Event emitter for dashboard ticker
./scripts_backup_2/_local/agent-runtime/matilda-auto-deploy-patch.js:17:    "ui/dashboard/ticker-events.log",
./scripts_backup_2/_local/agent-runtime/utils/clean_rogue_buttons.js:2:const filePath = 'ui/dashboard/index.html';
./reflections-sse-server.ts:12:  "<0001fa9e> Effie smiles: 'Heartbeat synchronized with dashboard feed.'",


# Missing Task Card Controls Inspection

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: dd526251d089c08547a97f87b06824b8794a038a
Candidate files scanned: 3794

## Search: Inspect Trace

TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt:1:===== TASK CARD STATUS TRACE PREVIEW FALLBACKS =====
PHASE740_BRIDGE_RESTORE_CHECKPOINT.md:26:  - Inspect trace
inspect-task-item-ui-wiring.sh:36:  grep -RniE "data-task|complete|retry|inspect|trace|json|task_id|taskId|recentTasks|renderRecent|phase717|phase719" public/index.html public/dashboard.html public/js/phase530_visible_panels_bridge.js | head -260 || true
RIO_DRIVE_MANUAL_CHECKPOINT_VERIFY.txt:1160:663d043c Restore task card status trace preview fallbacks
TASK_CARD_FALLBACK_UI_STATE_VERIFY.txt:5:663d043c Restore task card status trace preview fallbacks
restore-phase740-bridge-surgical.sh:34:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true
restore-phase740-bridge-surgical.sh:96:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true
missing-task-card-controls-inspection-20260528_212052.md:8:## Search: Inspect Trace
missing-task-card-controls-inspection-20260528_212052.md:10:TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt:1:===== TASK CARD STATUS TRACE PREVIEW FALLBACKS =====
missing-task-card-controls-inspection-20260528_212052.md:11:PHASE740_BRIDGE_RESTORE_CHECKPOINT.md:26:  - Inspect trace
missing-task-card-controls-inspection-20260528_212052.md:12:inspect-task-item-ui-wiring.sh:36:  grep -RniE "data-task|complete|retry|inspect|trace|json|task_id|taskId|recentTasks|renderRecent|phase717|phase719" public/index.html public/dashboard.html public/js/phase530_visible_panels_bridge.js | head -260 || true
missing-task-card-controls-inspection-20260528_212052.md:13:RIO_DRIVE_MANUAL_CHECKPOINT_VERIFY.txt:1160:663d043c Restore task card status trace preview fallbacks
missing-task-card-controls-inspection-20260528_212052.md:14:TASK_CARD_FALLBACK_UI_STATE_VERIFY.txt:5:663d043c Restore task card status trace preview fallbacks
missing-task-card-controls-inspection-20260528_212052.md:15:restore-phase740-bridge-surgical.sh:34:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true
missing-task-card-controls-inspection-20260528_212052.md:16:restore-phase740-bridge-surgical.sh:96:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true
missing-task-card-controls-inspection-20260528_212052.md:17:inspect-missing-task-card-controls.sh:82:    ("Inspect Trace", r"Inspect Trace|inspect trace|trace.*inspect|inspect.*trace|status trace|statusTrace"),
missing-task-card-controls-inspection-20260528_212052.md:18:TASK_PAYLOAD_SHAPE_GAP_INSPECTION.txt:223:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:19:DR_LAUNCHER_AND_MANUAL_CHECKPOINT_INSPECTION.txt:7:663d043c Restore task card status trace preview fallbacks
missing-task-card-controls-inspection-20260528_212052.md:20:MISSING_TASK_CARD_CONTROLS_INSPECTION.txt:28:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:21:MISSING_TASK_CARD_CONTROLS_INSPECTION.txt:180:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:22:MANUAL_DISASTER_CHECKPOINT_20260528_191555_0c04c71d.txt:7:663d043c Restore task card status trace preview fallbacks
missing-task-card-controls-inspection-20260528_212052.md:23:missing-task-card-controls-inspection-20260528_203345.md:8:## Search: Inspect Trace
missing-task-card-controls-inspection-20260528_212052.md:24:PHASE740_BRIDGE_SURGICAL_RESTORE.txt:21:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:25:PHASE740_BRIDGE_SURGICAL_RESTORE.txt:134:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:26:TASK_ITEM_UI_WIRING_INSPECTION.txt:178:public/js/phase530_visible_panels_bridge.js:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:27:TASK_ITEM_UI_WIRING_INSPECTION.txt:236:public/js/phase530_visible_panels_bridge.js:629:    const traceButton = event.target.closest("[data-phase717-inspect-trace]");
missing-task-card-controls-inspection-20260528_212052.md:28:TASK_ITEM_UI_WIRING_INSPECTION.txt:238:public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:29:restore-task-card-status-trace-preview-fallbacks.sh:74:  echo "===== TASK CARD STATUS TRACE PREVIEW FALLBACKS ====="
missing-task-card-controls-inspection-20260528_212052.md:30:restore-task-card-status-trace-preview-fallbacks.sh:100:git commit -m "Restore task card status trace preview fallbacks"
missing-task-card-controls-inspection-20260528_212052.md:31:PHASE530_BRIDGE_LINEAGE_INSPECTION.txt:1688:+          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:32:PHASE530_BRIDGE_LINEAGE_INSPECTION.txt:1911:+          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:33:TASK_CARD_FALLBACK_RECOVERY_SEAL.md:52:The current restored database rows do not contain artifact or trace payloads, so Preview and Inspect Trace can only appear when future or restored tasks include those fields.
missing-task-card-controls-inspection-20260528_212052.md:34:checkpoint-phase740-bridge-restore.sh:32:  - Inspect trace
missing-task-card-controls-inspection-20260528_212052.md:35:public/js/phase530_visible_panels_bridge.js:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:36:public/js/phase530_visible_panels_bridge.js:629:    const traceButton = event.target.closest("[data-phase717-inspect-trace]");
missing-task-card-controls-inspection-20260528_212052.md:37:public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:38:DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect t
missing-task-card-controls-inspection-20260528_212052.md:39:DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js:629:    const traceButton = event.target.closest("[data-phase717-inspect-trace]");
missing-task-card-controls-inspection-20260528_212052.md:40:DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:41:_dashboard_candidate_previews/rio-drive-runtime-artifacts/09-snapshots_full-disaster-recovery-20260526-phase743-sealed-13f8eb4a_Motherboard_Systems_HQ_DISASTER_RECOVERY_phase740-post-recovery-backup-2026-05-25T01-01-37_phase530_visible_panels_bridge.js:225:          ${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border
RESULT_LIMIT_REACHED

## Search: Inspect Logs

POST_PHASE715_DASHBOARD_CANDIDATES.txt:340:9878bc24 Phase 717: wire inspect logs chip
PHASE740_BRIDGE_RESTORE_CHECKPOINT.md:28:  - Inspect logs
apply-telemetry-console-polish.py:28:      if (label === "execution inspector" || label === "recent logs" || label === "recent tasks") {
restore-phase740-bridge-surgical.sh:34:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true
restore-phase740-bridge-surgical.sh:96:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true
missing-task-card-controls-inspection-20260528_212052.md:15:restore-phase740-bridge-surgical.sh:34:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true
missing-task-card-controls-inspection-20260528_212052.md:16:restore-phase740-bridge-surgical.sh:96:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true
missing-task-card-controls-inspection-20260528_212052.md:28:TASK_ITEM_UI_WIRING_INSPECTION.txt:238:public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:37:public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:40:DASHBOARD_UI_RECOVERY_ANCHORS/current-close-enough-ui-20260528_102016/public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:43:_dashboard_candidate_previews/rio-drive-runtime-artifacts/09-snapshots_full-disaster-recovery-20260526-phase743-sealed-13f8eb4a_Motherboard_Systems_HQ_DISASTER_RECOVERY_phase740-post-recovery-backup-2026-05-25T01-01-37_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:46:_dashboard_candidate_previews/rio-drive-runtime-artifacts/32-Motherboard_Storage_snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_checkpoints_PHASE721_PRE_SEMANTIC_OPERATOR_SUMMARY.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:61:_dashboard_candidate_previews/rio-drive-runtime-artifacts/40-Volumes_Rio_Drive_Motherboard_Systems_HQ_checkpoints_phase719_quarantined_failed_helpers_PHASE719_PHASE530_PRE_HTML_ARTIFACT_DIRECT_RENDER_V3.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:64:_dashboard_candidate_previews/rio-drive-runtime-artifacts/08-snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_DISASTER_RECOVERY_phase740-post-recovery-backup-2026-05-25T01-01-37_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:67:_dashboard_candidate_previews/rio-drive-runtime-artifacts/29-snapshots_full-disaster-recovery-20260526-phase743-sealed-13f8eb4a_Motherboard_Systems_HQ_checkpoints_phase725_aesthetic_refinement_baseline_phase530_visible_panels_bridge.pre_phase725_visual_polish.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:70:_dashboard_candidate_previews/rio-drive-runtime-artifacts/12-snapshots_full-disaster-recovery-20260526-phase743-sealed-13f8eb4a_Motherboard_Systems_HQ_public_js_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:73:_dashboard_candidate_previews/rio-drive-runtime-artifacts/10-Volumes_Rio_Drive_Motherboard_Systems_HQ_public_js_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:76:_dashboard_candidate_previews/rio-drive-runtime-artifacts/39-snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_checkpoints_phase719_quarantined_failed_helpers_PHASE719_PHASE530_PRE_HTML_HELPER_MINIMAL.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:79:_dashboard_candidate_previews/rio-drive-runtime-artifacts/30-snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_checkpoints_phase725_aesthetic_refinement_baseline_phase530_visible_panels_bridge.pre_phase725_visual_polish.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:82:_dashboard_candidate_previews/rio-drive-runtime-artifacts/27-snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_DISASTER_RECOVERY_phase735_runtime_alignment_20260519_150412_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:85:_dashboard_candidate_previews/rio-drive-runtime-artifacts/07-Volumes_Rio_Drive_Motherboard_Systems_HQ_DISASTER_RECOVERY_phase740-post-recovery-backup-2026-05-25T01-01-37_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:88:_dashboard_candidate_previews/rio-drive-runtime-artifacts/11-snapshots_full-disaster-recovery-20260526-phase744-architecture-494f61b3_Motherboard_Systems_HQ_public_js_phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:92:## Search: Inspect Logs
missing-task-card-controls-inspection-20260528_212052.md:94:POST_PHASE715_DASHBOARD_CANDIDATES.txt:340:9878bc24 Phase 717: wire inspect logs chip
missing-task-card-controls-inspection-20260528_212052.md:95:PHASE740_BRIDGE_RESTORE_CHECKPOINT.md:28:  - Inspect logs
missing-task-card-controls-inspection-20260528_212052.md:96:apply-telemetry-console-polish.py:28:      if (label === "execution inspector" || label === "recent logs" || label === "recent tasks") {
missing-task-card-controls-inspection-20260528_212052.md:97:restore-phase740-bridge-surgical.sh:34:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$SOURCE" | head -80 || true
missing-task-card-controls-inspection-20260528_212052.md:98:restore-phase740-bridge-surgical.sh:96:  grep -ni "data-phase719-preview-artifact\|data-phase717-requeue\|data-phase717-retry-differently\|Inspect details\|Inspect trace\|Inspect logs\|renderRecent\|taskRows" "$TARGET" | head -120 || true
missing-task-card-controls-inspection-20260528_212052.md:99:inspect-missing-task-card-controls.sh:84:    ("Inspect Logs", r"Inspect Logs|inspect logs|logs.*inspect|inspect.*logs|task logs|taskLogs|execution logs|executionLogs"),
missing-task-card-controls-inspection-20260528_212052.md:100:TASK_PAYLOAD_SHAPE_GAP_INSPECTION.txt:225:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:101:MISSING_TASK_CARD_CONTROLS_INSPECTION.txt:29:227:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:102:MISSING_TASK_CARD_CONTROLS_INSPECTION.txt:182:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:103:inspect-critical-recovery-corridors.sh:114:  echo "If governed smokes pass, live governed route returns ok:true, task health is 200, DB tables are present, and dashboard logs show no route crashes, the critical backend corridors are restored enough to stop broad inspection."
missing-task-card-controls-inspection-20260528_212052.md:104:PHASE740_BRIDGE_SURGICAL_RESTORE.txt:22:227:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:105:PHASE740_BRIDGE_SURGICAL_RESTORE.txt:135:227:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:106:TASK_ITEM_UI_WIRING_INSPECTION.txt:179:public/js/phase530_visible_panels_bridge.js:227:          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:107:TASK_ITEM_UI_WIRING_INSPECTION.txt:237:public/js/phase530_visible_panels_bridge.js:631:    const logsButton = event.target.closest("[data-phase717-inspect-logs]");
missing-task-card-controls-inspection-20260528_212052.md:108:TASK_ITEM_UI_WIRING_INSPECTION.txt:238:public/js/phase530_visible_panels_bridge.js:633:    const inspectionButton = detailButton || traceButton || logsButton;
missing-task-card-controls-inspection-20260528_212052.md:109:PHASE530_BRIDGE_LINEAGE_INSPECTION.txt:1690:+          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
missing-task-card-controls-inspection-20260528_212052.md:110:PHASE530_BRIDGE_LINEAGE_INSPECTION.txt:1913:+          ${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
RESULT_LIMIT_REACHED

## Search: Preview Pill / Preview Button

inspect-rio-drive-repo-bundle-dashboard-candidates-v2.sh:8:git add inspect-rio-drive-repo-bundle-dashboard-candidates-v2.py inspect-rio-drive-repo-bundle-dashboard-candidates-v2.sh RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt _dashboard_candidate_previews/rio-drive-repo-bundles-v2 || true
POST_PHASE715_DASHBOARD_CANDIDATES.txt:164:--- phase729-preview-aware-classification-sealed ---
POST_PHASE715_DASHBOARD_CANDIDATES.txt:166:commit: 2d4698f2 Phase 729 refine preview-aware semantic classification
POST_PHASE715_DASHBOARD_CANDIDATES.txt:186:--- phase731-preview-overlay-mock-validated ---
POST_PHASE715_DASHBOARD_CANDIDATES.txt:188:commit: 712704d9 Phase 731 ignore generated Preview overlay mocks
POST_PHASE715_DASHBOARD_CANDIDATES.txt:265:3c686916 Align single-container preview branch with template mount
POST_PHASE715_DASHBOARD_CANDIDATES.txt:271:e315e5fe Render visual artifacts as single preview container
POST_PHASE715_DASHBOARD_CANDIDATES.txt:272:61826658 Apply style intent theme to outer preview shell
POST_PHASE715_DASHBOARD_CANDIDATES.txt:274:6b56c073 Add request-scoped style intent preview renderer
POST_PHASE715_DASHBOARD_CANDIDATES.txt:275:682055ec Normalize escaped preview transport newlines
POST_PHASE715_DASHBOARD_CANDIDATES.txt:276:c0209605 Phase 725: polish visual preview shell
POST_PHASE715_DASHBOARD_CANDIDATES.txt:281:f90766c4 Phase 723: add inactive visual preview wrapper
POST_PHASE715_DASHBOARD_CANDIDATES.txt:288:f79a279a Phase 719: improve semantic artifact preview readability
POST_PHASE715_DASHBOARD_CANDIDATES.txt:290:385c0aa4 Phase 719: make inline semantic artifact preview primary
POST_PHASE715_DASHBOARD_CANDIDATES.txt:291:6cfc955b Phase 719: add visible fallback for artifact preview rendering
POST_PHASE715_DASHBOARD_CANDIDATES.txt:293:885839d4 Phase 719: expand artifact preview renderer sections
POST_PHASE715_DASHBOARD_CANDIDATES.txt:294:bb23656a Revert "Phase 719: patch artifact preview constraints"
POST_PHASE715_DASHBOARD_CANDIDATES.txt:295:3b12dd17 Phase 719: patch artifact preview constraints
POST_PHASE715_DASHBOARD_CANDIDATES.txt:300:436d2fd4 Revert "Phase 719: polish embedded artifact preview containment"
POST_PHASE715_DASHBOARD_CANDIDATES.txt:301:9e552128 Phase 719: polish embedded artifact preview containment
POST_PHASE715_DASHBOARD_CANDIDATES.txt:302:4a72fe1f Phase 719: apply isolated iframe artifact preview renderer
POST_PHASE715_DASHBOARD_CANDIDATES.txt:303:a1cce132 Phase 719: render artifact preview as visual card surface
POST_PHASE715_DASHBOARD_CANDIDATES.txt:304:bb3feaa4 Phase 719: render markdown artifact preview visually
POST_PHASE715_DASHBOARD_CANDIDATES.txt:305:858bee50 Phase 719: wire preview modal to artifact content
POST_PHASE715_DASHBOARD_CANDIDATES.txt:306:49d0e371 Phase 719: add frontend-only artifact preview modal
POST_PHASE715_DASHBOARD_CANDIDATES.txt:307:3b8f4829 Phase 719: replace lifecycle pill with conditional preview
POST_PHASE715_DASHBOARD_CANDIDATES.txt:339:cda0a3f3 Phase 717: move outcome preview to logs modal
PHASE39_PROJECT_INDEX_UPDATE.md:18:- Phase 40 shadow-mode preview
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:7:df310122 Record Rio Drive latest dashboard preview next step
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:10:07773bd9 Add dashboard candidate preview server
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:11:88215e45 Create dashboard candidate preview surfaces
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:39:open: http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/repo/index.html
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:56:open: http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/motherboard-systems-hq/index.html
RIO_DRIVE_REPO_BUNDLE_DASHBOARD_CANDIDATES_V2.txt:60:http://localhost:8099/_dashboard_candidate_previews/rio-drive-repo-bundles-v2/
TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt:1:===== TASK CARD STATUS TRACE PREVIEW FALLBACKS =====
TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt:9:       const outcome = esc(t.outcome_preview || "");
TASK_CARD_STATUS_TRACE_PREVIEW_FALLBACKS.txt:11:       const explanation = esc(t.explanation_preview || "");
restore-phase715-dashboard-candidate.sh:126:  grep -ni "execution inspector\|task history\|recent tasks\|artifact preview\|matilda\|operator guidance\|phase715\|phase719\|phase530" public/index.html | head -120 || true
enrich-api-tasks-response-shape.sh:76:        coalesce(payload->>'outcome_preview', metadata->>'outcome_preview') as outcome_preview,
enrich-api-tasks-response-shape.sh:78:        coalesce(payload->>'explanation_preview', notes, metadata->>'explanation_preview') as explanation_preview,
RESULT_LIMIT_REACHED

## Search: Recent Task Card Rendering

POST_PHASE715_DASHBOARD_CANDIDATES.txt:26:markers: Recent Tasks=3, Task History=1, Execution Inspector=1, Inspect=8, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:29:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:37:markers: Recent Tasks=3, Task History=1, Execution Inspector=1, Inspect=8, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:40:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:45:commit: 9e4e6dac Phase 717: seal recent tasks polish checkpoint
POST_PHASE715_DASHBOARD_CANDIDATES.txt:48:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:51:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:59:markers: Recent Tasks=3, Task History=1, Execution Inspector=1, Inspect=8, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:62:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:70:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:73:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:81:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:84:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:92:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=3, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:95:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:103:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:106:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:111:commit: 7bf706d2 Phase 719: disable legacy recent tasks renderer
POST_PHASE715_DASHBOARD_CANDIDATES.txt:114:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:117:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:125:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=3, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:128:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:136:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:139:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2
POST_PHASE715_DASHBOARD_CANDIDATES.txt:147:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:150:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:158:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:161:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:169:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:172:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:180:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:183:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:191:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:194:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:202:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:205:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:213:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:216:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
POST_PHASE715_DASHBOARD_CANDIDATES.txt:224:markers: Recent Tasks=3, Task History=1, Inspect=7, Retry=2, Requeue=1, Matilda=24, Operator Guidance=3, Agent Pool=3, telemetry=7, phase530=2, phase719=5
POST_PHASE715_DASHBOARD_CANDIDATES.txt:227:markers: Recent Tasks=2, Task History=1, Matilda=12, Operator Guidance=3, Agent Pool=1, telemetry=2, phase530=1, phase719=1
RESULT_LIMIT_REACHED


## API Shape Probe

{
    "api_probe": "not_run_or_unavailable",
    "reason": "localhost:3000 unavailable or curl failed"
}

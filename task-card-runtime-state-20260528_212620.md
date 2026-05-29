# Task Card Runtime State Inspection

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: 5b77664a3daf94fe60fbdf15be71f577cb20adc2

## Source Marker Verification

### data-phase717-inspect-trace
public/js/phase530_visible_panels_bridge.js:225:${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}
public/js/phase530_visible_panels_bridge.js:629:const traceButton = event.target.closest("[data-phase717-inspect-trace]");

### data-phase717-inspect-logs
public/js/phase530_visible_panels_bridge.js:227:${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}
public/js/phase530_visible_panels_bridge.js:631:const logsButton = event.target.closest("[data-phase717-inspect-logs]");

### data-phase719-preview-artifact
public/js/phase530_visible_panels_bridge.js:191:${artifactRaw ? `<button type="button" data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" data-artifact-name="${artifactName}" data-artifact-type="${artifactType}" data-artifact-size="${artifactSize}" data-artifact-path="${artifactPath}" data-artifact-outcome="${outcome}" data-artifact-explanation="${explanation}" title="Preview completed artifact" style="flex:0 0 auto;cursor:pointer;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;p
public/js/phase530_visible_panels_bridge.js:2450:const button = event.target.closest("[data-phase719-preview-artifact]");

### phase719-preview-modal
public/js/phase530_visible_panels_bridge.js:700:let modal = document.getElementById("phase719-preview-modal");
public/js/phase530_visible_panels_bridge.js:706:modal.id = "phase719-preview-modal";

### renderRecent
public/js/phase530_visible_panels_bridge.js:238:function renderRecent(tasks) {
public/js/phase530_visible_panels_bridge.js:677:renderRecent(data.tasks || []);

### traceJson
public/js/phase530_visible_panels_bridge.js:167:const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";
public/js/phase530_visible_panels_bridge.js:225:${traceJson ? `<button type="button" data-phase717-inspect-trace="true" data-phase717-inspect-title="${title} — Advanced trace" data-phase717-inspect-content="${traceJson}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(251,191,36,.38);background:rgba(120,53,15,.14);color:#fbbf24;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect trace</button>` : ""}

### logContent
public/js/phase530_visible_panels_bridge.js:169:const logContent = esc([
public/js/phase530_visible_panels_bridge.js:227:${logContent ? `<button type="button" data-phase717-inspect-logs="true" data-phase717-inspect-title="${title} — Logs" data-phase717-inspect-content="${logContent}" style="margin-top:10px;margin-left:6px;cursor:pointer;border:1px solid rgba(45,212,191,.38);background:rgba(20,83,45,.14);color:#5eead4;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect logs</button>` : ""}

### artifact
public/js/phase530_visible_panels_bridge.js:141:const artifactRaw = t.artifact || (Array.isArray(t.artifacts) ? t.artifacts[0] : null) || (t.payload && t.payload.artifact) || (t.payload && Array.isArray(t.payload.artifacts) ? t.payload.artifacts[0] : null) || (t.metadata && t.metadata.artifact) || (t.metadata && Array.isArray(t.metadata.artifacts) ? t.metadata.artifacts[0] : null) || null;
public/js/phase530_visible_panels_bridge.js:142:const artifactName = artifactRaw ? esc(artifactRaw.filename || artifactRaw.path || "artifact") : "";
public/js/phase530_visible_panels_bridge.js:143:const artifactType = artifactRaw ? esc(artifactRaw.type || "artifact") : "";
public/js/phase530_visible_panels_bridge.js:144:const artifactSize = artifactRaw && artifactRaw.size_bytes ? esc(String(artifactRaw.size_bytes) + " bytes") : "";
public/js/phase530_visible_panels_bridge.js:145:const artifactPath = artifactRaw ? esc(artifactRaw.path || "") : "";
public/js/phase530_visible_panels_bridge.js:191:${artifactRaw ? `<button type="button" data-phase719-preview-artifact="true" data-task-id="${taskId}" data-task-title="${title}" data-artifact-name="${artifactName}" data-artifact-type="${artifactType}" data-artifact-size="${artifactSize}" data-artifact-path="${artifactPath}" data-artifact-outcome="${outcome}" data-artifact-explanation="${explanation}" title="Preview completed artifact" style="flex:0 0 auto;cursor:pointer;color:#93c5fd;border:1px solid rgba(147,197,253,.35);border-radius:999px;p
public/js/phase530_visible_panels_bridge.js:208:${artifactRaw ? `<div style="margin-bottom:8px;color:#86efac;font-size:11px;line-height:1.5;overflow-wrap:anywhere;border:1px solid rgba(134,239,172,.28);border-radius:10px;padding:7px;background:rgba(20,83,45,.14);">Artifact: ${artifactName}${artifactType ? ` · ${artifactType}` : ""}${artifactSize ? ` · ${artifactSize}` : ""}</div>` : ""}
public/js/phase530_visible_panels_bridge.js:696:// Phase 719 — Preview artifact modal (frontend-only, read-only)
public/js/phase530_visible_panels_bridge.js:1058:return raw.replace(standardPrefix, "Prepared artifact for:").trim();
public/js/phase530_visible_panels_bridge.js:1092:.replace(/Prepared artifact for:/gi, "")
public/js/phase530_visible_panels_bridge.js:1154:<div data-phase719-rendered-artifact-preview="true" style="max-width:920px;margin:0 auto;">
public/js/phase530_visible_panels_bridge.js:1294:// Phase 723 — minimal visual artifact sanitizer helper (non-active)
RESULT_LIMIT_REACHED


## API Shape Probe

{
    "api_probe": "not_run_or_unavailable",
    "reason": "localhost:3000 unavailable or curl failed"
}

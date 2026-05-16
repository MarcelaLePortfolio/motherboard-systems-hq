
# Phase 726 Runtime Source Excerpts

## Purpose

This document captures focused read-only excerpts from the current runtime files that participate in artifact persistence, preview routing, and frontend rendering.

No runtime integration is performed by this step.

## Source Excerpt Capture

The command below appends current source excerpts into this document for review.


## server/routes/api-tasks-postgres.mjs — Artifact Preview Route Area

```js
});



// GET /api/tasks/:task_id/artifact-preview

apiTasksRouter.get("/:task_id/artifact-preview", async (req, res) => {

  try {

    const taskId = String(req.params.task_id || "").trim();

    if (!taskId) {

      return res.status(400).json({ ok: false, error: "task_id_required" });

    }

    const q = await globalThis.__DB_POOL.query(

      `

      SELECT

        completed.payload->'artifact' AS artifact,

        completed.payload->'artifacts' AS artifacts

      FROM tasks t

      LEFT JOIN LATERAL (

        SELECT te.payload

        FROM task_events te

        WHERE te.task_id = t.task_id

          AND te.kind = 'task.completed'

        ORDER BY te.ts DESC

        LIMIT 1

      ) completed ON true

      WHERE t.task_id = $1

      LIMIT 1

      `,

      [taskId]

    );

    const row = q.rows?.[0] || null;

    if (!row) {

      return res.status(404).json({ ok: false, error: "task_not_found" });

    }

    const artifact =

      row.artifact ||

      (Array.isArray(row.artifacts) ? row.artifacts[0] : null);

    if (!artifact || !artifact.path) {

      return res.status(404).json({ ok: false, error: "artifact_not_found" });

    }

    const artifactDir = process.env.MB_ARTIFACT_DIR || "/app/data/artifacts";

    const resolvedPath = path.resolve(String(artifact.path));

    const resolvedDir = path.resolve(artifactDir);

    if (!resolvedPath.startsWith(resolvedDir)) {

      return res.status(403).json({ ok: false, error: "artifact_path_rejected" });

    }

    if (!fs.existsSync(resolvedPath)) {

      return res.status(404).json({ ok: false, error: "artifact_file_missing" });

    }

    const content = fs.readFileSync(resolvedPath, "utf8");

    return res.status(200).json({

      ok: true,

      task_id: taskId,

      artifact: {

        filename: artifact.filename || null,

        type: artifact.type || null,

        size_bytes: artifact.size_bytes || null,

        created_at: artifact.created_at || null

      },

      content

    });

  } catch (e) {

    console.error("[phase719] artifact preview route error", e);

    return res.status(500).json({ ok: false, error: "artifact_preview_failed" });

  }

});


// POST /api/tasks/create  { task_id?, title?, agent?, run_id?, ... }
apiTasksRouter.post("/create", async (req, res) => {
```

## public/js/phase530_visible_panels_bridge.js — Preview Rendering Area

```js
        ? ["Operator Next Steps", semanticEnvelope.operator_next_steps]

        : null

    ].filter((entry) => entry && String(entry[1] || "").trim()) : [];

    const chips = [

      status ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(134,239,172,.38);background:rgba(20,83,45,.22);color:#bbf7d0;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(status)}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(147,197,253,.34);background:rgba(30,64,175,.22);color:#bfdbfe;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticType)}</span>`,

      semanticEnvelope ? `<span style="display:inline-flex;align-items:center;border:1px solid rgba(45,212,191,.34);background:rgba(20,184,166,.14);color:#99f6e4;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">semantic v${phase719EscapePreviewHtml(semanticEnvelope.semantic_version || "1")}</span>` : "",

      `<span style="display:inline-flex;align-items:center;border:1px solid rgba(251,191,36,.34);background:rgba(120,53,15,.18);color:#fde68a;border-radius:999px;padding:5px 10px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.08em;">${phase719EscapePreviewHtml(semanticPriority)}</span>`

    ].filter(Boolean).join("");

    return `

      <div data-phase719-rendered-artifact-preview="true" style="max-width:920px;margin:0 auto;">

        <div style="border:1px solid rgba(148,163,184,.22);border-radius:22px;overflow:hidden;background:radial-gradient(circle at top left, rgba(59,130,246,.18), transparent 34%),linear-gradient(180deg, rgba(15,23,42,.96), rgba(2,6,23,.9));box-shadow:0 24px 70px rgba(0,0,0,.42), inset 0 1px 0 rgba(255,255,255,.05);">

          <div style="padding:28px 30px 22px 30px;border-bottom:1px solid rgba(148,163,184,.16);">

            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px;">${chips}</div>

            <div style="font-size:30px;line-height:1.05;font-weight:900;letter-spacing:-.04em;color:#f8fafc;margin-bottom:12px;">${phase719EscapePreviewHtml(title)}</div>

            ${task ? `<div style="font-size:15px;line-height:1.55;color:#cbd5e1;max-width:760px;">${phase719EscapePreviewHtml(task)}</div>` : ""}

          </div>

          ${semanticOperatorSummary.length ? `

            <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:12px;padding:22px 24px 0 24px;">

              <section style="border:1px solid rgba(45,212,191,.24);border-radius:18px;background:rgba(6,78,59,.18);padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:12px;">Semantic Insights</div>

                <div style="display:grid;gap:10px;">

                  ${semanticOperatorSummary.map(([label, value]) => `

                    <div style="border-top:1px solid rgba(45,212,191,.16);padding-top:10px;">

                      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.16em;color:#99f6e4;font-weight:900;margin-bottom:5px;">${phase719EscapePreviewHtml(label)}</div>

                      <div style="font-size:14px;line-height:1.55;color:#ccfbf1;white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

                    </div>

                  `).join("")}

                </div>

              </section>

            </div>

          ` : ""}

          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:${semanticOperatorSummary.length ? "14px" : "22px"} 24px 10px 24px;">

            ${enrichedSections.map(([label, value]) => `

              <section style="border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#93c5fd;font-weight:900;margin-bottom:10px;">${phase719EscapePreviewHtml(label)}</div>

                <div style="font-size:15px;line-height:1.6;color:#e0f2fe;white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

              </section>

            `).join("")}

          </div>

          <div style="display:grid;grid-template-columns:minmax(0,1.2fr) minmax(220px,.8fr);gap:18px;padding:12px 24px 24px 24px;">

            <section style="border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#93c5fd;font-weight:900;margin-bottom:10px;">Outcome</div>

              <div style="font-size:17px;line-height:1.55;color:#e0f2fe;font-weight:650;">${phase719EscapePreviewHtml(displayOutcome || "No outcome content available.")}</div>

            </section>

            <section style="border:1px solid rgba(45,212,191,.20);border-radius:18px;background:rgba(6,78,59,.16);padding:18px;">

              <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:10px;">Build Path</div>

              <div style="font-size:14px;line-height:1.55;color:#ccfbf1;white-space:pre-wrap;">${phase719EscapePreviewHtml(explanation || "No explanation available.")}</div>

            </section>

          </div>

        </div>

      </div>

    `;

  }

  function phase719RenderArtifactIframePreview(renderedHtml) {

    const srcdoc = [

      "<!DOCTYPE html>",

      "<html>",

      "<head>",

      "<meta charset=\"utf-8\">",

      "<style>",

      "html,body{margin:0;padding:0;background:#020617;color:#e5e7eb;font-family:Inter,system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;}",

      "body{padding:18px;overflow-wrap:anywhere;}",

      "*{box-sizing:border-box;max-width:100%;}",

      "</style>",

      "</head>",

      "<body>",

      String(renderedHtml || ""),

      "</body>",

      "</html>"

    ].join("");

    return `

      <iframe

        title="Artifact rendered preview"

        sandbox=""

        srcdoc="${phase719EscapePreviewHtml(srcdoc)}"

        style="display:block;width:100%;min-height:560px;border:1px solid rgba(148,163,184,.24);border-radius:16px;background:#020617;"

      ></iframe>

    `;

  }

  // Phase 723 — minimal visual artifact sanitizer helper (non-active)

  function phase723SanitizeVisualArtifactHtml(html) {

    const source = String(html || "");

    const withoutUnsafeBlocks = source

      .replace(/<\s*script\b[\s\S]*?<\s*\/\s*script\s*>/gi, "")

      .replace(/<\s*style\b[\s\S]*?<\s*\/\s*style\s*>/gi, "")

      .replace(/<\s*iframe\b[\s\S]*?<\s*\/\s*iframe\s*>/gi, "")

      .replace(/<\s*object\b[\s\S]*?<\s*\/\s*object\s*>/gi, "")

      .replace(/<\s*embed\b[\s\S]*?>/gi, "")

      .replace(/<\s*link\b[\s\S]*?>/gi, "")

      .replace(/<\s*meta\b[\s\S]*?>/gi, "");

    return withoutUnsafeBlocks

      .replace(/\s+on[a-z]+\s*=\s*"[^"]*"/gi, "")

      .replace(/\s+on[a-z]+\s*=\s*'[^']*'/gi, "")

      .replace(/\s+on[a-z]+\s*=\s*[^\s>]+/gi, "")

      .replace(/\s+(href|src)\s*=\s*"javascript:[^"]*"/gi, "")

      .replace(/\s+(href|src)\s*=\s*'javascript:[^']*'/gi, "")

      .replace(/\s+(href|src)\s*=\s*javascript:[^\s>]+/gi, "");

  }

  // Phase 723 — visual artifact block extraction helper (non-active)

  function phase723ExtractVisualArtifactBlock(markdown) {

    const source = String(markdown || "");

    const startMarker = "<!-- visual-artifact:start -->";

    const endMarker = "<!-- visual-artifact:end -->";

    const startIndex = source.indexOf(startMarker);

    const endIndex = source.indexOf(endMarker);

    if (startIndex === -1 || endIndex === -1 || endIndex <= startIndex) {

      return {

        hasVisualArtifact: false,

        visualHtml: "",

        markdownWithoutVisualArtifact: source

      };

    }

    const visualStart = startIndex + startMarker.length;

    const visualHtml = source.slice(visualStart, endIndex).trim();

    const markdownWithoutVisualArtifact = (

      source.slice(0, startIndex) + source.slice(endIndex + endMarker.length)

    ).trim();

    return {

      hasVisualArtifact: Boolean(visualHtml),

      visualHtml,

      markdownWithoutVisualArtifact

    };

  }

  // Phase 723 — embedded visual artifact preview wrapper (non-active)

  function phase723RenderVisualArtifactPreviewCandidate(markdown) {

    const extracted = phase723ExtractVisualArtifactBlock(markdown);

    const fallbackMarkdown = extracted.markdownWithoutVisualArtifact || String(markdown || "");

    const fallbackPreview = phase719RenderArtifactVisualCard(fallbackMarkdown);

    if (!extracted.hasVisualArtifact) {

      return fallbackPreview;

    }

    const safeVisualHtml = phase723SanitizeVisualArtifactHtml(extracted.visualHtml);

    if (!safeVisualHtml) {

      return fallbackPreview;

    }

    return `

      <div data-phase723-visual-artifact-preview="true" style="max-width:960px;margin:0 auto 22px auto;border:1px solid rgba(45,212,191,.32);background:linear-gradient(135deg,rgba(15,23,42,.78),rgba(8,47,73,.46));border-radius:26px;padding:22px;box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.06);">

        <div style="display:flex;align-items:center;justify-content:space-between;gap:14px;margin-bottom:18px;">

          <div style="font-size:12px;text-transform:uppercase;letter-spacing:.2em;color:#ccfbf1;font-weight:950;text-shadow:0 0 22px rgba(45,212,191,.18);">Visual Artifact</div>

          <div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#dbeafe;border:1px solid rgba(147,197,253,.34);border-radius:999px;padding:5px 10px;background:rgba(30,64,175,.22);box-shadow:inset 0 1px 0 rgba(255,255,255,.05);">sanitized html subset</div>

        </div>

        <div data-phase723-visual-artifact-body="true" style="overflow:auto;border-radius:20px;background:rgba(2,6,23,.46);border:1px solid rgba(148,163,184,.24);padding:18px;color:#e5e7eb;box-shadow:inset 0 1px 0 rgba(255,255,255,.04);">

          ${safeVisualHtml}

        </div>

      </div>

    `;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const visualCandidate = phase723RenderVisualArtifactPreviewCandidate(markdown);

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      return `

        <div data-phase724-visual-only-preview="true" style="display:grid;gap:12px;">

          ${visualCandidate}

        </div>

      `;

    }

    const rendered = visualCandidate;

    return `

      <div data-phase719-preview-stack="true" style="display:grid;gap:12px;">

        <div data-phase719-inline-preview-primary="true" style="border:1px solid rgba(96,165,250,.22);border-radius:16px;padding:0;background:rgba(15,23,42,.34);">

          ${rendered}

        </div>

      </div>

    `;

  }



  async function phase719OpenPreviewModal(button) {

    const modal = phase719EnsurePreviewModal();

    const title = modal.querySelector("#phase719-preview-title");

    const subtitle = modal.querySelector("#phase719-preview-subtitle");

    const meta = modal.querySelector("#phase719-preview-meta");

    const body = modal.querySelector("#phase719-preview-body");

    const taskTitle = button.getAttribute("data-task-title") || "Artifact Preview";

    const taskId = button.getAttribute("data-task-id") || "";

    const fallbackName = button.getAttribute("data-artifact-name") || "artifact";

    const fallbackType = button.getAttribute("data-artifact-type") || "artifact";

    const fallbackSize = button.getAttribute("data-artifact-size") || "";

    const fallbackPath = button.getAttribute("data-artifact-path") || "";

    const fallbackOutcome = button.getAttribute("data-artifact-outcome") || "";

    const fallbackExplanation = button.getAttribute("data-artifact-explanation") || "";

    title.textContent = "Preview: " + taskTitle;

    subtitle.textContent = taskId ? "task_id: " + taskId : "";

    meta.textContent = [

      "artifact: " + fallbackName,

      fallbackType ? "type: " + fallbackType : "",

      fallbackSize ? "size: " + fallbackSize : "",

      fallbackPath ? "path: " + fallbackPath : ""

    ].filter(Boolean).join("\n");

    body.innerHTML = `<div style="color:#93c5fd;font-size:14px;">Loading rendered artifact preview…</div>`;

    modal.style.display = "flex";

    if (!taskId) {

      body.textContent = "No task id available for artifact preview.";

      return;

    }

    try {

      const res = await fetch(`/api/tasks/${encodeURIComponent(taskId)}/artifact-preview`, { cache: "no-store" });

      const data = await res.json().catch(() => null);

      if (!res.ok || !data || data.ok !== true) {

        body.textContent = [

          "Rendered artifact content is not available.",

          data && data.error ? "Error: " + data.error : "",

          fallbackOutcome ? "\nOutcome:\n" + fallbackOutcome : "",

          fallbackExplanation ? "\nExplanation:\n" + fallbackExplanation : ""

        ].filter(Boolean).join("\n");

        return;

      }

      const artifact = data.artifact || {};

      const renderedName = artifact.filename || fallbackName;

      const renderedType = artifact.type || fallbackType;

      const renderedSize = artifact.size_bytes ? String(artifact.size_bytes) + " bytes" : fallbackSize;

      const renderedCreated = artifact.created_at || "";

      meta.textContent = [

        "artifact: " + renderedName,

        renderedType ? "type: " + renderedType : "",

        renderedSize ? "size: " + renderedSize : "",

        renderedCreated ? "created: " + renderedCreated : ""

      ].filter(Boolean).join("\n");

      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

    } catch (error) {

      body.textContent = [

        "Preview fetch failed.",

        error && error.message ? error.message : String(error),

        fallbackOutcome ? "\nOutcome:\n" + fallbackOutcome : "",

        fallbackExplanation ? "\nExplanation:\n" + fallbackExplanation : ""
```

## server/artifacts.mjs

```js
/**
 * Artifacts SSE + small in-memory replay.
 * Artifacts must originate server-side (no client synthesis).
 */
const clients = new Set();
let ring = [];
const RING_MAX = 100;

function sseWrite(res, line) {
  try {
    res.write(line);
    res.flush?.();
  } catch {
    clients.delete(res);
  }
}

export function attachArtifacts(app) {
  app.get("/events/artifacts", (req, res) => {
  console.log("[ARTIFACTS] SSE client connected");
    res.status(200);
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache, no-transform");
    res.setHeader("Connection", "keep-alive");
    res.setHeader("X-Accel-Buffering", "no");
    res.flushHeaders?.();

    clients.add(res);

  console.log("[ARTIFACTS] clients=", clients.size);
    // immediate output so curl isn't a blank screen
    sseWrite(res, `: connected ${new Date().toISOString()}\n\n`);

    // replay
    for (const a of ring) {
      sseWrite(res, `data: ${JSON.stringify(a)}\n\n`);
    }

    req.on("close", () => {
    console.log("[ARTIFACTS] SSE client disconnected");
    console.log("[ARTIFACTS] clients=", clients.size);
      clients.delete(res);
      try { res.end(); } catch {}
    });
  });

  // keepalive ping (prevents buffering/timeouts)
  setInterval(() => {
    for (const res of clients) {
      sseWrite(res, `: ping ${new Date().toISOString()}\n\n`);
    }
  }, 15000);

  app.post("/api/artifacts", (req, res) => {
    emitArtifact({
      ...(req.body || {}),
      timestamp: new Date().toISOString(),
    });
    res.json({ ok: true });
  });

  return { emitArtifact };
}

export function emitArtifact(artifact) {
  const a = {
    type: artifact?.type || "log",
    source: artifact?.source || "unknown",
    taskId: artifact?.taskId,
    timestamp: artifact?.timestamp || new Date().toISOString(),
    payload: artifact?.payload ?? {},
  };

  ring.push(a);
  if (ring.length > RING_MAX) ring = ring.slice(-RING_MAX);

  for (const res of clients) {
    sseWrite(res, `data: ${JSON.stringify(a)}\n\n`);
  }
}
```

## server/worker/response_compiler.mjs

```js
function normalizeString(value, fallback = "") {
  const text = String(value ?? "").trim();
  return text || fallback;
}

function extractExecution(contractedExecution = {}) {
  if (contractedExecution?.execution && typeof contractedExecution.execution === "object") {
    return contractedExecution.execution;
  }

  return {};
}

export function compileCommunicationResult(task = {}, contractedExecution = {}, options = {}) {
  const execution = extractExecution(contractedExecution);

  const taskId = task.task_id ?? task.id ?? null;
  const runId = task.run_id ?? null;

  const outcomeContent = normalizeString(
    execution.output,
    "Execution completed."
  );

  const explanationContent = normalizeString(
    execution.notes,
    "No additional explanation available."
  );

  const strategyApplied = normalizeString(
    execution.strategy_applied,
    "default"
  );

  return {
    outcome: {
      tier: "TIER_1",
      purpose: "operator-safe outcome",
      content: outcomeContent,
      visibility: "default"
    },

    explanation: {
      tier: "TIER_2",
      purpose: "brief causal explanation",
      content: explanationContent,
      visibility: "on_request",
      persistence: "non_sticky"
    },

    systemTrace: {
      tier: "TIER_3",
      purpose: "internal/system execution trace",
      content: {
        task_id: taskId,
        run_id: runId,
        strategy_applied: strategyApplied,
        execution_meta: execution.meta && typeof execution.meta === "object" ? execution.meta : {},
        compiler_options: options && typeof options === "object" ? options : {}
      },
      visibility: "explicit_access_only",
      persistence: "non_default"
    }
  };
}

export default compileCommunicationResult;
```

## server/worker/task_execution_interpreter.mjs

```js

function unwrapPayload(value) {

  if (!value) return {};

  if (typeof value === "object") return value;

  try {

    return JSON.parse(String(value));

  } catch {

    return {};

  }

}

function extractMeta(task = {}) {

  const payload = unwrapPayload(task.payload);

  return payload?.meta || task?.meta || {};

}

function escapeHtml(value) {

  return String(value || "")

    .replace(/&/g, "&amp;")

    .replace(/</g, "&lt;")

    .replace(/>/g, "&gt;")

    .replace(/"/g, "&quot;");

}

function detectVisualArtifactIntent(title = "") {

  const text = String(title || "").toLowerCase();

  const hasVisualLanguage =

    /\bvisual\b/.test(text) ||

    /\bpreviewable\b/.test(text) ||

    /\blanding\s*(page|card)\b/.test(text) ||

    /\bcard\b/.test(text) ||

    /\bhero\b/.test(text) ||

    /\bui\b/.test(text) ||

    /\bmockup\b/.test(text);

  const hasBuildLanguage =

    /\bcreate\b/.test(text) ||

    /\bbuild\b/.test(text) ||

    /\bgenerate\b/.test(text) ||

    /\bmake\b/.test(text) ||

    /\bdesign\b/.test(text);

  return hasVisualLanguage && hasBuildLanguage;

}

function inferBrandName(title = "") {

  const source = String(title || "");

  const calledMatch = source.match(/called\s+([A-Z][A-Za-z0-9 '&-]{2,60})/);

  if (calledMatch?.[1]) return calledMatch[1].trim().replace(/[.?!].*$/, "");

  const forMatch = source.match(/for\s+([A-Z][A-Za-z0-9 '&-]{2,60})/);

  if (forMatch?.[1]) return forMatch[1].trim().replace(/[.?!].*$/, "");

  return "Preview Concept";

}

function buildVisualArtifactOutput(title = "") {

  const brand = inferBrandName(title);

  const safeBrand = escapeHtml(brand);

  const safeTitle = escapeHtml(title);

  const headline = /moonrise/i.test(brand)

    ? "Warm pastries for quiet mornings."

    : `A polished visual concept for ${safeBrand}.`;

  return `# ${safeBrand} Visual Artifact

## Summary

Preview-ready visual artifact generated from delegated visual intent.

<!-- visual-artifact:start -->

<div style="border:1px solid rgba(251,191,36,.35);border-radius:26px;padding:26px;background:linear-gradient(135deg,rgba(30,41,59,.96),rgba(120,53,15,.34));box-shadow:0 22px 70px rgba(0,0,0,.28);">

  <div style="display:flex;justify-content:space-between;gap:18px;align-items:flex-start;margin-bottom:22px;">

    <div>

      <div style="font-size:11px;text-transform:uppercase;letter-spacing:.2em;color:#fde68a;font-weight:900;margin-bottom:10px;">${safeBrand}</div>

      <div style="font-size:34px;line-height:1.02;font-weight:950;color:#fff7ed;margin-bottom:12px;">${headline}</div>

      <div style="font-size:15px;line-height:1.7;color:#fed7aa;max-width:620px;">A warm, premium preview card generated automatically from the delegation request.</div>

    </div>

    <div style="border:1px solid rgba(253,230,138,.35);border-radius:999px;padding:9px 13px;color:#fef3c7;background:rgba(120,53,15,.28);font-size:12px;font-weight:800;white-space:nowrap;">Preview Ready</div>

  </div>

  <div style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px;margin-top:18px;">

    <div style="border:1px solid rgba(251,191,36,.24);border-radius:18px;padding:16px;background:rgba(15,23,42,.34);">

      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#fde68a;font-weight:900;margin-bottom:8px;">Hero</div>

      <div style="font-size:18px;font-weight:850;color:#fff7ed;margin-bottom:6px;">Brand story</div>

      <div style="font-size:13px;line-height:1.55;color:#fed7aa;">A headline-first section for positioning and first impression.</div>

    </div>

    <div style="border:1px solid rgba(251,191,36,.24);border-radius:18px;padding:16px;background:rgba(15,23,42,.34);">

      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#fde68a;font-weight:900;margin-bottom:8px;">Offer</div>

      <div style="font-size:18px;font-weight:850;color:#fff7ed;margin-bottom:6px;">Core promise</div>

      <div style="font-size:13px;line-height:1.55;color:#fed7aa;">Feature cards for the main offer, service, or product experience.</div>

    </div>

    <div style="border:1px solid rgba(251,191,36,.24);border-radius:18px;padding:16px;background:rgba(15,23,42,.34);">

      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.14em;color:#fde68a;font-weight:900;margin-bottom:8px;">CTA</div>

      <div style="font-size:18px;font-weight:850;color:#fff7ed;margin-bottom:6px;">Reserve a box</div>

      <div style="font-size:13px;line-height:1.55;color:#fed7aa;">A simple next action designed for conversion.</div>

    </div>

  </div>

</div>

<!-- visual-artifact:end -->

## Deliverable

A previewable visual artifact for: ${safeBrand}

## Outcome

Generated visual artifact content from delegated visual intent.

## Next Steps

Open Preview and confirm the visual card renders above the semantic fallback.

## Request

${safeTitle}`;

}

export function interpretTaskExecution(task = {}) {

  const payload = unwrapPayload(task.payload);

  const meta = extractMeta(task);

  const title = task.title || payload.title || "Untitled task";

  const executionMode = payload.execution_mode || "standard";

  const cachePolicy = payload.cache_policy || "reuse";

  const memoryScope = payload.memory_scope || "preserve";

  const isPolicyAware =

    executionMode === "rebuild_context" ||

    cachePolicy === "bypass" ||

    memoryScope === "reset_partial";

  if (isPolicyAware) {

    const notes = [

      executionMode === "rebuild_context" ? "fresh context requested" : null,

      cachePolicy === "bypass" ? "cache bypass observed" : null,

      memoryScope === "reset_partial" ? "partial memory reset observed" : null

    ].filter(Boolean).join("; ");

    return {

      ok: true,

      strategy_applied: "prompt_augmentation",

      notes,

      output: `Policy-aware execution prepared for: ${title}`,

      meta: {

        ...meta,

        execution_mode: executionMode,

        cache_policy: cachePolicy,

        memory_scope: memoryScope

      }

    };

  }

  if (meta?.retry_mode === "strategy_shift") {

    return {

      ok: true,

      strategy_applied: "prompt_augmentation",

      notes: meta.instruction || "strategy shift applied",

      output: `Strategy-shift execution prepared for: ${title}`,

      meta

    };

  }

  if (detectVisualArtifactIntent(title)) {

    return {

      ok: true,

      strategy_applied: "prompt_augmentation",

      notes: "visual artifact intent detected",

      output: buildVisualArtifactOutput(title),

      meta: {

        ...meta,

        visual_artifact: true,

        visual_artifact_strategy: "visual_artifact_generation"

      }

    };

  }

  return {

    ok: true,

    strategy_applied: "default",

    notes: "standard execution path",

    output: `Standard execution prepared for: ${title}`,

    meta

  };

}

```

## server/worker/execute_task_with_contract.mjs

```js
import { interpretTaskExecution } from "./task_execution_interpreter.mjs";
import { safeExecutionContract } from "./execution_contract.mjs";
import { compileCommunicationResult } from "./response_compiler.mjs";

export function executeTaskWithContract(task) {
  const executionResult = interpretTaskExecution(task);
  const contractedExecution = safeExecutionContract(task, executionResult);

  if (!contractedExecution.ok) {
    throw new Error(`[worker][execution-contract] ${contractedExecution.error || "EXECUTION_CONTRACT_FAILED"}`);
  }

  console.log("[worker][execution-contract]", {
    task_id: task.task_id,
    strategy_applied: contractedExecution.execution.strategy_applied,
    notes: contractedExecution.execution.notes,
    output: contractedExecution.execution.output
  });

  const communicationResult = compileCommunicationResult(task, contractedExecution);

  console.log("[worker][response-compiler]", {
    task_id: task.task_id,
    outcome_preview: communicationResult.outcome.content,
    explanation_preview: communicationResult.explanation.content
  });

  return {
    ...contractedExecution,
    communicationResult
  };
}
```

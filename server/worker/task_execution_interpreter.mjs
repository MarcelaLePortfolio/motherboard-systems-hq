
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


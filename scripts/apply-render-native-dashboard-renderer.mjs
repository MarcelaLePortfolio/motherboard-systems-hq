
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("phase736RenderNativeDashboardHtml")) {

  console.log("Render-native dashboard renderer already present.");

  process.exit(0);

}

const guardName = "function phase736RenderNativeDashboardGuard(payload)";

const guardIndex = original.indexOf(guardName);

if (guardIndex === -1) {

  console.error(`Unable to locate guard function: ${guardName}`);

  process.exit(1);

}

const nextFunctionIndex = original.indexOf("\nfunction ", guardIndex + guardName.length);

if (nextFunctionIndex === -1) {

  console.error("Unable to identify insertion boundary after guard.");

  process.exit(1);

}

const insertion = `

function phase736EscapeRenderNativeText(value) {

  return String(value ?? "")

    .replace(/&/g, "&amp;")

    .replace(/</g, "&lt;")

    .replace(/>/g, "&gt;")

    .replace(/"/g, "&quot;")

    .replace(/'/g, "&#039;");

}

function phase736RenderNativeToneClass(tone) {

  const normalized = String(tone || "info").toLowerCase();

  if (normalized.includes("ready")) return "phase736-tone-ready";

  if (normalized.includes("blocked")) return "phase736-tone-blocked";

  if (normalized.includes("warning")) return "phase736-tone-warning";

  if (normalized.includes("critical")) return "phase736-tone-critical";

  return "phase736-tone-info";

}

function phase736RenderNativePanel(panel) {

  const payload = panel && panel.payload ? panel.payload : {};

  const type = phase736EscapeRenderNativeText(panel && panel.type ? panel.type : "panel");

  const title = phase736EscapeRenderNativeText(payload.title || panel?.title || type);

  const accent = phase736EscapeRenderNativeText(panel?.styling?.accent || "teal");

  const tone = phase736RenderNativeToneClass(payload.tone || panel?.styling?.accent || "info");

  if (panel?.renderer === "status-card-grid" && Array.isArray(payload.cards)) {

    return \`

      <section class="phase736-render-panel phase736-panel-status-grid phase736-accent-\${accent}">

        <div class="phase736-panel-kicker">\${type}</div>

        <h3>\${title}</h3>

        <div class="phase736-status-grid">

          \${payload.cards.map((card) => \`

            <article class="phase736-status-card \${phase736RenderNativeToneClass(card.tone)}">

              <span class="phase736-status-label">\${phase736EscapeRenderNativeText(card.label)}</span>

              <strong>\${phase736EscapeRenderNativeText(card.status)}</strong>

              <p>\${phase736EscapeRenderNativeText(card.detail)}</p>

            </article>

          \`).join("")}

        </div>

      </section>

    \`;

  }

  if (panel?.renderer === "topology-map" && Array.isArray(payload.nodes)) {

    return \`

      <section class="phase736-render-panel phase736-panel-topology phase736-accent-\${accent}">

        <div class="phase736-panel-kicker">\${type}</div>

        <h3>\${title}</h3>

        <div class="phase736-topology-map">

          \${payload.nodes.map((node) => \`

            <div class="phase736-topology-node \${phase736RenderNativeToneClass(node.tone)}">

              <span>\${phase736EscapeRenderNativeText(node.stage)}</span>

              <strong>\${phase736EscapeRenderNativeText(node.label)}</strong>

            </div>

          \`).join('<div class="phase736-topology-connector">→</div>')}

        </div>

      </section>

    \`;

  }

  if (panel?.renderer === "risk-card-grid" && Array.isArray(payload.risks)) {

    return \`

      <section class="phase736-render-panel phase736-panel-risk-grid phase736-accent-\${accent}">

        <div class="phase736-panel-kicker">\${type}</div>

        <h3>\${title}</h3>

        <div class="phase736-risk-grid">

          \${payload.risks.map((risk) => \`

            <article class="phase736-risk-card \${phase736RenderNativeToneClass(risk.severity)}">

              <strong>\${phase736EscapeRenderNativeText(risk.label)}</strong>

              <p>\${phase736EscapeRenderNativeText(risk.description)}</p>

              <small>\${phase736EscapeRenderNativeText(risk.mitigation)}</small>

            </article>

          \`).join("")}

        </div>

      </section>

    \`;

  }

  if (panel?.type === "governance-boundary" && Array.isArray(payload.requirements)) {

    return \`

      <section class="phase736-render-panel phase736-panel-governance phase736-accent-amber">

        <div class="phase736-panel-kicker">governance</div>

        <h3>\${title}</h3>

        <ul>

          \${payload.requirements.map((item) => \`<li>\${phase736EscapeRenderNativeText(item)}</li>\`).join("")}

        </ul>

      </section>

    \`;

  }

  return \`

    <section class="phase736-render-panel \${tone} phase736-accent-\${accent}">

      <div class="phase736-panel-kicker">\${type}</div>

      <h3>\${title}</h3>

      <p>\${phase736EscapeRenderNativeText(payload.body || payload.subtitle || "")}</p>

      \${Array.isArray(payload.highlights) ? \`

        <div class="phase736-highlight-list">

          \${payload.highlights.map((item) => \`<span>\${phase736EscapeRenderNativeText(item)}</span>\`).join("")}

        </div>

      \` : ""}

    </section>

  \`;

}

function phase736RenderNativeDashboardHtml(renderNativePayload) {

  const dashboard =

    renderNativePayload?.dashboard ||

    renderNativePayload?.payload?.dashboard ||

    renderNativePayload;

  const panels = Array.isArray(dashboard?.panels)

    ? dashboard.panels

    : Array.isArray(renderNativePayload?.runtimeComposition?.panels)

      ? renderNativePayload.runtimeComposition.panels

      : [];

  const title = phase736EscapeRenderNativeText(dashboard?.title || renderNativePayload?.dashboardShell?.title || "Render-Native Dashboard");

  const subtitle = phase736EscapeRenderNativeText(dashboard?.subtitle || renderNativePayload?.dashboardShell?.subtitle || "Governed visual artifact");

  const theme = dashboard?.theme || renderNativePayload?.dashboardShell?.theme || {};

  const accents = Array.isArray(theme.accents) ? theme.accents : ["teal", "violet", "amber", "coral", "emerald"];

  return \`

    <div class="phase736-render-native-dashboard" data-phase736-render-native-dashboard="true">

      <style>

        .phase736-render-native-dashboard {

          background: radial-gradient(circle at top left, rgba(45, 212, 191, 0.24), transparent 34%),

                      radial-gradient(circle at top right, rgba(168, 85, 247, 0.22), transparent 30%),

                      linear-gradient(135deg, #07111f 0%, #111827 48%, #1e1b4b 100%);

          color: #f8fafc;

          border-radius: 24px;

          padding: 24px;

          font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;

          box-shadow: 0 24px 80px rgba(15, 23, 42, 0.42);

        }

        .phase736-dashboard-hero {

          display: grid;

          gap: 12px;

          margin-bottom: 22px;

          padding: 22px;

          border: 1px solid rgba(148, 163, 184, 0.24);

          border-radius: 22px;

          background: rgba(15, 23, 42, 0.62);

          backdrop-filter: blur(16px);

        }

        .phase736-dashboard-hero h2 {

          margin: 0;

          font-size: clamp(1.7rem, 3vw, 2.8rem);

          letter-spacing: -0.04em;

        }

        .phase736-dashboard-hero p {

          margin: 0;

          color: #cbd5e1;

        }

        .phase736-dashboard-badges {

          display: flex;

          flex-wrap: wrap;

          gap: 8px;

        }

        .phase736-dashboard-badges span,

        .phase736-highlight-list span {

          border: 1px solid rgba(255, 255, 255, 0.18);

          border-radius: 999px;

          padding: 6px 10px;

          background: rgba(255, 255, 255, 0.08);

          color: #e2e8f0;

          font-size: 0.78rem;

          text-transform: uppercase;

          letter-spacing: 0.08em;

        }

        .phase736-render-grid {

          display: grid;

          grid-template-columns: repeat(12, minmax(0, 1fr));

          gap: 18px;

        }

        .phase736-render-panel {

          grid-column: span 6;

          border: 1px solid rgba(148, 163, 184, 0.22);

          border-radius: 20px;

          padding: 18px;

          background: rgba(15, 23, 42, 0.64);

          backdrop-filter: blur(18px);

          box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.07), 0 16px 40px rgba(0, 0, 0, 0.24);

        }

        .phase736-panel-status-grid,

        .phase736-panel-topology {

          grid-column: span 12;

        }

        .phase736-panel-kicker {

          color: #67e8f9;

          font-size: 0.72rem;

          text-transform: uppercase;

          letter-spacing: 0.14em;

          margin-bottom: 8px;

        }

        .phase736-render-panel h3 {

          margin: 0 0 12px;

          font-size: 1.05rem;

        }

        .phase736-status-grid,

        .phase736-risk-grid {

          display: grid;

          grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));

          gap: 12px;

        }

        .phase736-status-card,

        .phase736-risk-card,

        .phase736-topology-node {

          border-radius: 16px;

          padding: 14px;

          background: rgba(255, 255, 255, 0.08);

          border: 1px solid rgba(255, 255, 255, 0.13);

        }

        .phase736-status-card strong,

        .phase736-topology-node strong {

          display: block;

          margin-top: 5px;

          font-size: 1rem;

        }

        .phase736-status-card p,

        .phase736-risk-card p,

        .phase736-risk-card small,

        .phase736-render-panel p {

          color: #cbd5e1;

          line-height: 1.45;

        }

        .phase736-topology-map {

          display: flex;

          flex-wrap: wrap;

          align-items: center;

          gap: 10px;

        }

        .phase736-topology-connector {

          color: #94a3b8;

        }

        .phase736-tone-ready {

          box-shadow: 0 0 0 1px rgba(52, 211, 153, 0.26);

        }

        .phase736-tone-warning {

          box-shadow: 0 0 0 1px rgba(251, 191, 36, 0.32);

        }

        .phase736-tone-blocked,

        .phase736-tone-critical {

          box-shadow: 0 0 0 1px rgba(251, 113, 133, 0.34);

        }

        .phase736-highlight-list {

          display: flex;

          flex-wrap: wrap;

          gap: 8px;

          margin-top: 12px;

        }

        @media (max-width: 860px) {

          .phase736-render-panel {

            grid-column: span 12;

          }

        }

      </style>

      <header class="phase736-dashboard-hero">

        <div class="phase736-dashboard-badges">

          <span>READ-ONLY</span>

          <span>NO MUTATION</span>

          <span>RENDER-NATIVE</span>

          \${accents.slice(0, 5).map((accent) => \`<span>\${phase736EscapeRenderNativeText(accent)}</span>\`).join("")}

        </div>

        <h2>\${title}</h2>

        <p>\${subtitle}</p>

      </header>

      <main class="phase736-render-grid">

        \${panels.map(phase736RenderNativePanel).join("")}

      </main>

    </div>

  \`;

}

`;

const patched =

  original.slice(0, nextFunctionIndex) +

  insertion +

  original.slice(nextFunctionIndex);

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      insertedRenderer: "phase736RenderNativeDashboardHtml",

      insertionBoundary: nextFunctionIndex,

      preserveFallbacks: true,

      routeActivated: false

    },

    null,

    2

  )

);


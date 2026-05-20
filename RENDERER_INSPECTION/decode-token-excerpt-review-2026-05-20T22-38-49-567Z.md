# Decode Token Excerpt Review

Source inspection: RENDERER_INSPECTION/decode-token-shape-2026-05-20T22-37-25-065Z.json
Target file: public/js/phase530_visible_panels_bridge.js
Token count: 4

Purpose:

Review actual decode/render path shape before the third route-activation attempt.

If the next route activation attempt fails, revert to the last stable renderer baseline before trying a different hypothesis class.

## Token index 56398

```js
ow: 0 0 0 1px rgba(251, 113, 133, 0.34);

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

          ${accents.slice(0, 5).map((accent) => `<span>${phase736EscapeRenderNativeText(accent)}</span>`).join("")}

        </div>

        <h2>${title}</h2>

        <p>${subtitle}</p>

      </header>

      <main class="phase736-render-grid">

        ${panels.map(phase736RenderNativePanel).join("")}

      </main>

    </div>

  `;

}

phase735DecodeVisualArtifactHtmlTransport(html) {

    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\n/g, "\n")

      .replace(/\\\\\"/g, '"')

      .replace(/\\\\'/g, "'")

      .replace(/style="\\+"/g, 'style="')

      .replace(/;\\+"/g, ';')

      .replace(/\\+"=/g, '=');

    const textarea = document.createElement("textarea");

    textarea.innerHTML = source;

    return textarea.value;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      const decodedVisualHtml = phase735DecodeVisualArtifactHtmlTransport(extractedVisual.visualHtml);

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);

      return `

        <div

          data-phase733-single-artifact-render="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisu
```

## Token index 57060

```js
.join("")}

        </div>

        <h2>${title}</h2>

        <p>${subtitle}</p>

      </header>

      <main class="phase736-render-grid">

        ${panels.map(phase736RenderNativePanel).join("")}

      </main>

    </div>

  `;

}

phase735DecodeVisualArtifactHtmlTransport(html) {

    const source = phase733NormalizePreviewTransportText(html || "")

      .replace(/\\\\n/g, "\n")

      .replace(/\\\\\"/g, '"')

      .replace(/\\\\'/g, "'")

      .replace(/style="\\+"/g, 'style="')

      .replace(/;\\+"/g, ';')

      .replace(/\\+"=/g, '=');

    const textarea = document.createElement("textarea");

    textarea.innerHTML = source;

    return textarea.value;

  }

  function phase719RenderMarkdownArtifactPreview(markdown) {

    const extractedVisual = phase723ExtractVisualArtifactBlock(markdown);

    if (extractedVisual.hasVisualArtifact) {

      const decodedVisualHtml = phase735DecodeVisualArtifactHtmlTransport(extractedVisual.visualHtml);

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);

      return `

        <div

          data-phase733-single-artifact-render="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisualHtml)}</template>

        </div>

      `;

    }

    const strippedFallback = phase720StripSemanticEnvelope(markdown);

    const decodedFallback = phase735DecodeVisualArtifactHtmlTransport(strippedFallback);

    const fallbackLooksLikeHtml = /<\s*div\b|<\s*section\b|<\s*article\b/i.test(decodedFallback);

    if (fallbackLooksLikeHtml) {

      const safeFallbackHtml = phase723SanitizeVisualArtifactHtml(decodedFallback);

      return `

        <div

          data-phase733-single-artifact-render="true"

          data-phase735-fallback-html-artifact="true"

          style="

            max-width:1040px;

            margin:0 auto;

           
```

## Token index 57992

```js
Transport(extractedVisual.visualHtml);

      const safeVisualHtml = phase723SanitizeVisualArtifactHtml(decodedVisualHtml);

      return `

        <div

          data-phase733-single-artifact-render="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeVisualHtml)}</template>

        </div>

      `;

    }

    const strippedFallback = phase720StripSemanticEnvelope(markdown);

    const decodedFallback = phase735DecodeVisualArtifactHtmlTransport(strippedFallback);

    const fallbackLooksLikeHtml = /<\s*div\b|<\s*section\b|<\s*article\b/i.test(decodedFallback);

    if (fallbackLooksLikeHtml) {

      const safeFallbackHtml = phase723SanitizeVisualArtifactHtml(decodedFallback);

      return `

        <div

          data-phase733-single-artifact-render="true"

          data-phase735-fallback-html-artifact="true"

          style="

            max-width:1040px;

            margin:0 auto;

            border:1px solid rgba(148,163,184,.28);

            border-radius:22px;

            padding:18px;

            background:rgba(15,23,42,.42);

            box-shadow:0 24px 80px rgba(0,0,0,.32), inset 0 1px 0 rgba(255,255,255,.05);

            overflow:auto;

          "

        >

          <div data-phase735-visual-html-mount="true"></div>

          <template data-phase735-visual-html-template="true">${phase719EscapePreviewHtml(safeFallbackHtml)}</template>

        </div>

      `;

    }

    return `

      <div

        data-phase733-single-artifact-render-fallback="true"

        style="

          max-width:920px;

          margin:0 auto;

          border:1px solid rgba(148,163,184,.28);

          border-radius:22px;

          padding:22px;

          background:rgba(15,23,42,.72);

          color:#e5e7eb;

          white-space:pre-wrap;

          overflow-wrap:anywhere;

        "

      >${phase7
```

## Token index 62769

```js
fallbackType;

      const renderedSize = artifact.size_bytes ? String(artifact.size_bytes) + " bytes" : fallbackSize;

      const renderedCreated = artifact.created_at || "";

      meta.textContent = [

        "artifact: " + renderedName,

        renderedType ? "type: " + renderedType : "",

        renderedSize ? "size: " + renderedSize : "",

        renderedCreated ? "created: " + renderedCreated : ""

      ].filter(Boolean).join("\n");

      body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content);

      body.querySelectorAll("[data-phase735-visual-html-mount]").forEach((phase735Mount) => {

        const template = phase735Mount.parentElement

          ? phase735Mount.parentElement.querySelector("[data-phase735-visual-html-template]")

          : null;

        const templateHtml = template ? template.textContent : "";

        try {

          const decoded = phase735DecodeVisualArtifactHtmlTransport(templateHtml);

          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);

          if (template) template.remove();

        } catch (error) {

          phase735Mount.textContent = "Unable to render artifact preview.";

        }

      });

    } catch (error) {

      body.textContent = [

        "Preview fetch failed.",

        error && error.message ? error.message : String(error),

        fallbackOutcome ? "\nOutcome:\n" + fallbackOutcome : "",

        fallbackExplanation ? "\nExplanation:\n" + fallbackExplanation : ""

      ].filter(Boolean).join("\n");

    }

  }


  document.addEventListener("click", function (event) {

    const button = event.target.closest("[data-phase719-preview-artifact]");

    if (!button) return;

    event.preventDefault();

    phase719OpenPreviewModal(button);

  });


})();

```


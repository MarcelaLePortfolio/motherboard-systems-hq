
# Phase 735 Runtime Script Content Validation

## Current Evidence

Browser runtime reports:

- exactly one relevant bridge script loaded

- no Phase 735 mount/template nodes present in live preview DOM

## Interpretation

The browser may still be executing:

- an older cached version of the bridge script

- a transformed/minified variant

- a stale service-worker/browser-cached asset

## Next Browser Console Step

Paste this into DevTools Console:

(() => {

  const script = [...document.scripts].find((s) =>

    (s.src || "").includes("phase530_visible_panels_bridge.js")

  );

  if (!script) {

    console.log("PHASE735: target script not found");

    return;

  }

  fetch(script.src, { cache: "reload" })

    .then((r) => r.text())

    .then((text) => {

      console.log("PHASE735 SCRIPT CONTENT CHECK", {

        src: script.src,

        hasMountNode: text.includes("data-phase735-visual-html-mount"),

        hasTemplateNode: text.includes("data-phase735-visual-html-template"),

        hasDecodeHelper: text.includes("phase735DecodeVisualArtifactHtmlTransport"),

        hasOldWrapper: text.includes("sanitized html subset"),

        preview: text.slice(1380, 1900)

      });

    });

})();

## Goal

Verify whether the browser-loaded bridge script actually contains the Phase 735 runtime code.

## Boundary

No renderer mutation until runtime script contents are confirmed.


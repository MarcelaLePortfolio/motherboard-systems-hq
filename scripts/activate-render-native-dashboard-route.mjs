
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("phase736RenderNativeDashboardHtml(renderNativeRoute.payload)")) {

  console.log("Render-native dashboard route already activated.");

  process.exit(0);

}

const targetSnippet = `

const renderNativeRoute =

      phase736RenderNativeDashboardGuard(payload);

`;

if (!original.includes(targetSnippet)) {

  console.error("Unable to locate render-native guard invocation.");

  process.exit(1);

}

const insertion = `

const renderNativeRoute =

      phase736RenderNativeDashboardGuard(payload);

    if (

      renderNativeRoute &&

      renderNativeRoute.renderNative === true

    ) {

      try {

        const renderNativeHtml =

          phase736RenderNativeDashboardHtml(

            renderNativeRoute.payload

          );

        if (

          renderNativeHtml &&

          typeof renderNativeHtml === "string"

        ) {

          return renderNativeHtml;

        }

      } catch (error) {

        console.warn(

          "[phase736] render-native renderer failed, falling back",

          error

        );

      }

    }

`;

const patched = original.replace(

  targetSnippet,

  insertion

);

if (patched === original) {

  console.error("Route activation patch failed.");

  process.exit(1);

}

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      routeActivated: true,

      renderer: "phase736RenderNativeDashboardHtml",

      preserveFallbacks: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      fallbackBehavior:

        "legacy semantic artifact rendering remains active if render-native route fails"

    },

    null,

    2

  )

);


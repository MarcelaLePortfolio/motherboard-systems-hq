
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("phase736RouteDecodedPreviewHtml")) {

  console.log("Sanitizer expression render-native route already present.");

  process.exit(0);

}

const helperMarker = "function phase736RenderNativeDashboardHtml";

const helperIndex = original.indexOf(helperMarker);

if (helperIndex === -1) {

  console.error(`Unable to locate renderer helper marker: ${helperMarker}`);

  process.exit(1);

}

const decodeToken = "phase735DecodeVisualArtifactHtmlTransport(";

const sanitizeToken = "phase723SanitizeVisualArtifactHtml(";

const decodeIndexes = [];

let searchIndex = 0;

while ((searchIndex = original.indexOf(decodeToken, searchIndex)) !== -1) {

  decodeIndexes.push(searchIndex);

  searchIndex += decodeToken.length;

}

if (decodeIndexes.length < 4) {

  console.error(`Expected at least 4 decode call-sites, found ${decodeIndexes.length}`);

  process.exit(1);

}

const targetDecodeIndex = decodeIndexes[3];

const sanitizeStart = original.lastIndexOf(sanitizeToken, targetDecodeIndex);

if (sanitizeStart === -1) {

  console.error("Unable to locate sanitizer wrapper before target decode call.");

  process.exit(1);

}

const statementStart = original.lastIndexOf("\n", sanitizeStart) + 1;

const statementEnd = original.indexOf(";", targetDecodeIndex);

if (statementStart <= 0 || statementEnd === -1) {

  console.error("Unable to isolate sanitizer statement.");

  process.exit(1);

}

const originalStatement = original.slice(statementStart, statementEnd + 1);

if (!originalStatement.includes(sanitizeToken) || !originalStatement.includes(decodeToken)) {

  console.error("Target statement does not contain expected sanitizer/decode expression.");

  process.exit(1);

}

const helperInsertion = `

function phase736RouteDecodedPreviewHtml(rawTransportValue, legacyHtml) {

  try {

    const renderNativePayload =

      phase736RenderNativeDashboardGuard(rawTransportValue);

    if (

      renderNativePayload &&

      renderNativePayload.renderNative === true

    ) {

      const renderNativeHtml =

        phase736RenderNativeDashboardHtml(

          renderNativePayload.payload

        );

      if (

        renderNativeHtml &&

        typeof renderNativeHtml === "string"

      ) {

        return renderNativeHtml;

      }

    }

  } catch (error) {

    console.warn(

      "[phase736] sanitizer expression render-native route fallback",

      error

    );

  }

  return legacyHtml;

}

`;

const replacementStatement = originalStatement.replace(

  /phase723SanitizeVisualArtifactHtml\(\s*phase735DecodeVisualArtifactHtmlTransport\(([^)]*)\)\s*\)/,

  "phase736RouteDecodedPreviewHtml($1, phase723SanitizeVisualArtifactHtml(phase735DecodeVisualArtifactHtmlTransport($1)))"

);

if (replacementStatement === originalStatement) {

  console.error("Unable to transform sanitizer/decode expression.");

  process.exit(1);

}

const patchedWithHelper =

  original.slice(0, helperIndex) +

  helperInsertion +

  original.slice(helperIndex);

const adjustedStatementStart =

  statementStart + helperInsertion.length;

const adjustedStatementEnd =

  statementEnd + 1 + helperInsertion.length;

const finalPatched =

  patchedWithHelper.slice(0, adjustedStatementStart) +

  replacementStatement +

  patchedWithHelper.slice(adjustedStatementEnd);

fs.writeFileSync(resolvedTarget, finalPatched);

console.log(

  JSON.stringify(

    {

      targetFile,

      activatedRoute: "phase736RouteDecodedPreviewHtml",

      targetDecodeIndex,

      preserveFallbacks: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      mutationScope: "single sanitizer/decode preview expression"

    },

    null,

    2

  )

);


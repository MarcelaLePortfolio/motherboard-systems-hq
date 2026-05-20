
import fs from "fs";

import path from "path";

function latestFile(dir, prefix) {

  const files = fs

    .readdirSync(dir)

    .filter((file) => file.startsWith(prefix) && file.endsWith(".json"))

    .map((file) => path.join(dir, file))

    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);

  if (!files.length) {

    throw new Error(`No matching files for ${prefix}`);

  }

  return files[0];

}

const sourceFile = latestFile("RENDERER_INSPECTION", "decode-token-shape-");

const source = JSON.parse(fs.readFileSync(sourceFile, "utf8"));

const excerptFile = path.join(

  "RENDERER_INSPECTION",

  `decode-token-excerpt-review-${new Date().toISOString().replace(/[:.]/g, "-")}.md`

);

const sections = [

  "# Decode Token Excerpt Review",

  "",

  `Source inspection: ${sourceFile}`,

  `Target file: ${source.targetFile}`,

  `Token count: ${source.count}`,

  "",

  "Purpose:",

  "",

  "Review actual decode/render path shape before the third route-activation attempt.",

  "",

  "If the next route activation attempt fails, revert to the last stable renderer baseline before trying a different hypothesis class.",

  "",

];

for (const context of source.contexts || []) {

  sections.push(`## Token index ${context.index}`);

  sections.push("");

  sections.push("```js");

  sections.push(context.excerpt);

  sections.push("```");

  sections.push("");

}

fs.writeFileSync(excerptFile, `${sections.join("\n")}\n`);

console.log(`Decode token excerpt review written: ${excerptFile}`);


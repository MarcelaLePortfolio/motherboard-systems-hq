import fs from "node:fs";

const target = "server.mjs";
const source = fs.readFileSync(target, "utf8");

let updated = source;

const importLine = 'import systemHealthRouter from "./routes/diagnostics/systemHealth.js";';

if (!updated.includes(importLine)) {
  const lines = updated.split("\n");

  let insertIndex = 0;
  while (insertIndex < lines.length && /^\s*import\b/.test(lines[insertIndex])) {
    insertIndex += 1;
  }

  lines.splice(insertIndex, 0, importLine);
  updated = lines.join("\n");
}

const mountLines = [
  'app.use("/diagnostics/system-health", systemHealthRouter);',
  'app.use("/diagnostics/systemHealth", systemHealthRouter);',
];

if (!updated.includes(mountLines[0])) {
  const apiTasksMutationsPattern = /(app\.use\("\/api\/tasks-mutations",\s*apiTasksMutationsRouter\);\s*)/;

  if (!apiTasksMutationsPattern.test(updated)) {
    throw new Error('Mount anchor app.use("/api/tasks-mutations", apiTasksMutationsRouter); not found in server.mjs');
  }

  updated = updated.replace(
    apiTasksMutationsPattern,
    `$1\n${mountLines.join("\n")}\n`
  );
}

fs.writeFileSync(target, updated);
console.log("Patched server.mjs");

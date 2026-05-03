import fs from "fs";

const main = process.argv[2];
if (!main) {
  console.error("usage: node scripts/phase19_patch_mount_tasks_mutations.mjs <mainfile>");
  process.exit(2);
}

let src = fs.readFileSync(main, "utf8");

const importLine = `import apiTasksMutationsRouter from "./server/routes/api-tasks-mutations.mjs";`;
const hasImport = src.includes(importLine) || src.includes("api-tasks-mutations.mjs");
if (!hasImport) {
  // Insert after the last top-level import statement.
  const importMatches = [...src.matchAll(/^import .*$/gm)];
  if (importMatches.length === 0) {
    console.error("ERR: no ES imports found to anchor insertion in", main);
    process.exit(1);
  }
  const last = importMatches[importMatches.length - 1];
  const insertAt = last.index + last[0].length;
  src = src.slice(0, insertAt) + "\n" + importLine + "\n" + src.slice(insertAt);
}

const mountNeedle = "app.use(apiTasksMutationsRouter)";
if (!src.includes(mountNeedle)) {
  // Prefer mounting after existing /api/tasks router if present; else after last app.use(...)
  const apiTasksUse = src.match(/app\.use\((?:["'`][^"'`]*\/api\/tasks[^"'`]*["'`]\s*,\s*)?apiTasksRouter\);/);
  if (apiTasksUse?.index != null) {
    const idx = apiTasksUse.index + apiTasksUse[0].length;
    src = src.slice(0, idx) + "\n" + mountNeedle + ";\n" + src.slice(idx);
  } else {
    const uses = [...src.matchAll(/app\.use\([^\n]*\);\s*/g)];
    if (uses.length === 0) {
      console.error("ERR: no app.use(...) anchors found in", main);
      process.exit(1);
    }
    const lastUse = uses[uses.length - 1];
    const idx = lastUse.index + lastUse[0].length;
    src = src.slice(0, idx) + "\n" + mountNeedle + ";\n" + src.slice(idx);
  }
}

fs.writeFileSync(main, src, "utf8");
console.log("patched:", main);

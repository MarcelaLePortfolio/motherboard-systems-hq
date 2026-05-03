#!/usr/bin/env node
import fs from "fs";
import path from "path";

const ROOT = process.cwd();

// Strings we keep seeing on the dashboard
const NEEDLES = [
  "Dashboard v2.0.3 · Phase 11.3 (Matilda chat) · container :8080 — unified chat + diagnostics layout loaded",
  "Matilda is currently using a placeholder /api/chat stub (Phase 11.3 baseline).",
];

const REPLACEMENTS = new Map([
  [
    NEEDLES[0],
    "Dashboard v2.1.0 · Phase 14 (ops reliability) · container :8080 — unified chat + diagnostics layout loaded",
  ],
  [
    NEEDLES[1],
    "Matilda chat is wired to /api/chat (server-side). If you see a stub reply, it means the backend is intentionally in placeholder mode.",
  ],
]);

function walk(dir) {
  const out = [];
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    if (ent.name === "node_modules" || ent.name === ".git" || ent.name === "dist") continue;
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}

function isTextFile(p) {
  const okExt = new Set([".html", ".js", ".mjs", ".css"]);
  return okExt.has(path.extname(p));
}

const candidates = walk(ROOT).filter((p) => {
  if (!p.includes(`${path.sep}public${path.sep}`)) return false;
  return isTextFile(p);
});

let changed = 0;
let hits = 0;

for (const file of candidates) {
  let s;
  try {
    s = fs.readFileSync(file, "utf8");
  } catch {
    continue;
  }

  let next = s;
  for (const [from, to] of REPLACEMENTS.entries()) {
    if (next.includes(from)) {
      hits++;
      next = next.split(from).join(to);
    }
  }

  if (next !== s) {
    fs.writeFileSync(file, next, "utf8");
    changed++;
    console.log("patched:", path.relative(ROOT, file));
  }
}

if (!hits) {
  console.log("no matches found (nothing to patch)");
  process.exit(2);
}

console.log(`done: ${changed} file(s) updated`);

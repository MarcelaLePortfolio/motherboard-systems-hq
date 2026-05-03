import fs from "node:fs";
import path from "node:path";

const INJECT = 'import "./task-events-sse-listener.js";\n';

const CANDIDATES = [
  "public/js/dashboard-bundle-entry.js",
  "public/js/dashboard-bundle-entry.mjs",
  "public/js/dashboard-stream.js",
  "public/dashboard-stream.js",
  "public/js/dashboard-status.js",
  "public/dashboard-status.js",
  "public/js/dashboard-ops-reflections-ui.js",
  "public/scripts/dashboard-ops.js",
  "public/scripts/dashboard-reflections.js",
];

function exists(p) { try { fs.accessSync(p); return true; } catch { return false; } }
function read(p) { return fs.readFileSync(p, "utf8"); }
function write(p, s) { fs.writeFileSync(p, s, "utf8"); }

function injectIntoFile(fp) {
  const s = read(fp);
  if (s.includes("task-events-sse-listener.js")) return { fp, changed: false, why: "already" };

  // If ESM-ish, inject after imports; otherwise just prepend a require-compatible shim via dynamic import.
  const isESM = /^\s*import\s/m.test(s) || /export\s/m.test(s);

  if (isESM) {
    const lines = s.split("\n");
    let insertAt = 0;
    // place after initial import block if present
    for (let i = 0; i < lines.length; i++) {
      if (/^\s*import\s/.test(lines[i]) || /^\s*$/.test(lines[i])) insertAt = i + 1;
      else break;
    }
    lines.splice(insertAt, 0, INJECT.trimEnd());
    write(fp, lines.join("\n") + "\n");
    return { fp, changed: true, mode: "esm" };
  }

  // CJS fallback: inject a tiny dynamic import (won't break if ignored)
  const shim = `\n;(()=>{try{import("./task-events-sse-listener.js")}catch(e){}})();\n`;
  write(fp, shim + s);
  return { fp, changed: true, mode: "cjs-shim" };
}

const touched = [];

for (const c of CANDIDATES) {
  if (!exists(c)) continue;
  const res = injectIntoFile(c);
  if (res.changed) { touched.push(res.fp); break; }
}

if (touched.length === 0) {
  // fallback scan: find first public/js file that already references ops/reflections SSE and patch it
  const root = "public";
  const stack = [root];
  while (stack.length && touched.length === 0) {
    const dir = stack.pop();
    for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
      const fp = path.join(dir, ent.name);
      if (ent.isDirectory()) stack.push(fp);
      else if (ent.isFile() && fp.endsWith(".js")) {
        const s = read(fp);
        if (s.includes("/events/ops") || s.includes("/events/reflections") || s.includes("EventSource(")) {
          const res = injectIntoFile(fp);
          if (res.changed) touched.push(res.fp);
          break;
        }
      }
    }
  }
}

console.log(JSON.stringify({ ok: true, touched }, null, 2));

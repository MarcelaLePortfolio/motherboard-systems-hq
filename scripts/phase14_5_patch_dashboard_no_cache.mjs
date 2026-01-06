#!/usr/bin/env node
import fs from "fs";
import path from "path";

const ROOT = process.cwd();

function read(p) { return fs.readFileSync(p, "utf8"); }
function write(p, s) { fs.writeFileSync(p, s, "utf8"); }
function exists(p) { return fs.existsSync(p); }

function ensureNoCacheMeta(html) {
  if (html.includes('http-equiv="Cache-Control"') || html.includes("http-equiv='Cache-Control'")) return html;

  const meta = [
    '  <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0" />',
    '  <meta http-equiv="Pragma" content="no-cache" />',
    '  <meta http-equiv="Expires" content="0" />',
  ].join("\n") + "\n";

  // Insert immediately after <head ...>
  return html.replace(/<head([^>]*)>\s*\n?/i, (m) => `${m}\n${meta}`);
}

function bustBundleUrls(html, version) {
  // bust /bundle.js and /bundle.css (and any "bundle" variants you may have)
  html = html.replace(/(["'])\/bundle\.js(\?[^"']*)?\1/g, `$1/bundle.js?v=${version}$1`);
  html = html.replace(/(["'])\/bundle\.css(\?[^"']*)?\1/g, `$1/bundle.css?v=${version}$1`);

  // also bust any "dashboard" bundle if present
  html = html.replace(/(["'])\/js\/dashboard-bundle-entry\.js(\?[^"']*)?\1/g, `$1/js/dashboard-bundle-entry.js?v=${version}$1`);

  return html;
}

function ensureBuildBannerId(html) {
  // If already present, do nothing.
  if (html.includes('id="dashboard-build-banner"')) return html;

  // Common patterns for your blue “diagnostics” line:
  // - a div/span containing "Dashboard" and "Phase"
  // We'll wrap the first matching text node in a span with the id.
  const patterns = [
    /(<[^>]+>\s*)([^<]*Dashboard[^<]*Phase[^<]*)(\s*<\/[^>]+>)/i,
    /(<[^>]+>\s*)([^<]*Dashboard[^<]*)(\s*<\/[^>]+>)/i,
  ];

  for (const re of patterns) {
    const m = html.match(re);
    if (m) {
      const [full, open, text, close] = m;
      const replaced = `${open}<span id="dashboard-build-banner">${text}</span>${close}`;
      return html.replace(full, replaced);
    }
  }

  // If we can't find it safely, just leave HTML unchanged.
  return html;
}

function patchHtmlFile(relPath, version) {
  const p = path.join(ROOT, relPath);
  if (!exists(p)) return { file: relPath, changed: false, reason: "missing" };

  let html = read(p);
  const before = html;

  html = ensureNoCacheMeta(html);
  html = bustBundleUrls(html, version);
  html = ensureBuildBannerId(html);

  if (html !== before) {
    write(p, html);
    return { file: relPath, changed: true };
  }
  return { file: relPath, changed: false };
}

function patchAgentStatusRow() {
  const p = path.join(ROOT, "public/scripts/agent-status-row.js");
  if (!exists(p)) return { file: "public/scripts/agent-status-row.js", changed: false, reason: "missing" };

  let s = read(p);
  const before = s;

  // Replace the old “find by Dashboard v2.0.3 text” anchor logic with an id-based anchor.
  // We do this with a broad but safe replacement: if file contains the old marker string, swap the whole anchor finder block.
  if (s.includes('includes("Dashboard v2.0.3")') || s.includes("Dashboard v2.0.3")) {
    // Minimal rewrite: define a helper getAnchor() and use it where the old code did.
    s = s.replace(
      /\/\/ 🧭 Find the blue diagnostics line[\s\S]*?append(?:ing)? to body instead"\);\n/mi,
      `// 🧭 Anchor: prefer stable id on the build/diagnostics banner
function __mbhqFindAnchor() {
  const byId = document.getElementById("dashboard-build-banner");
  if (byId) return byId;

  // fallback: first element that contains "Dashboard" and "Phase"
  const all = Array.from(document.querySelectorAll("body *"));
  const hit = all.find(el => {
    const t = (el && el.textContent) ? el.textContent : "";
    return t.includes("Dashboard") && t.includes("Phase");
  });
  if (hit) return hit;

  console.warn("⚠️ Could not find dashboard-build-banner anchor — appending to body instead");
  return document.body;
}
`
    );

    // Also replace any remaining direct search loops that key off the old string.
    s = s.replace(/if\s*\(\s*el\.textContent\.includes\(["']Dashboard v2\.0\.3["']\)\s*\)\s*\{\s*anchor\s*=\s*el;\s*\}/g, "");
  }

  // Ensure the script uses the anchor helper if it exists.
  if (s.includes("__mbhqFindAnchor") && !s.includes("const anchor = __mbhqFindAnchor")) {
    s = s.replace(
      /let\s+anchor\s*=\s*null;?/,
      `const anchor = __mbhqFindAnchor();`
    );
    s = s.replace(/if\s*\(!anchor\)\s*\{[\s\S]*?\}\s*/m, "");
  }

  if (s !== before) {
    write(p, s);
    return { file: "public/scripts/agent-status-row.js", changed: true };
  }
  return { file: "public/scripts/agent-status-row.js", changed: false };
}

const version = String(Date.now());

const results = [];
results.push(patchHtmlFile("public/dashboard.html", version));
results.push(patchHtmlFile("public/index.html", version));
results.push(patchAgentStatusRow());

for (const r of results) {
  if (r.changed) console.log("patched:", r.file);
  else console.log("ok:", r.file, r.reason ? `(${r.reason})` : "");
}

import fs from "fs";

const file = "server.mjs";
let s = fs.readFileSync(file, "utf8");
const before = s;

function addNoStoreBeforeSendFile(block) {
  if (block.includes('Cache-Control", "no-store')) return block; // idempotent
  return block.replace(
    /return\s+res\.sendFile\(/,
    [
      '  res.set("Cache-Control", "no-store, must-revalidate");',
      '  res.set("Pragma", "no-cache");',
      '  res.set("Expires", "0");',
      '  return res.sendFile('
    ].join("\n")
  );
}

// /dashboard route
s = s.replace(
  /(app\.get\(\s*["']\/dashboard["'][\s\S]*?\{\s*[\s\S]*?)(return\s+res\.sendFile\([\s\S]*?\);\s*\n\s*\}\);)/,
  (m) => addNoStoreBeforeSendFile(m)
);

// SPA fallback route
s = s.replace(
  /(app\.use\(\(req,\s*res,\s*next\)\s*=>\s*\{\s*[\s\S]*?)(return\s+res\.sendFile\([\s\S]*?\);\s*\n\s*\}\);)/,
  (m) => addNoStoreBeforeSendFile(m)
);

if (s === before) {
  console.log("⚠️ No changes made (patterns not found or already patched).");
} else {
  fs.writeFileSync(file, s, "utf8");
  console.log("✅ Patched server.mjs (no-store headers for HTML sendFile routes)");
}

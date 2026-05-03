const fs = require("fs");

const file = "public/js/phase61_recent_history_wire.js";
let src = fs.readFileSync(file, "utf8");

if (!src.includes("function renderGuidance(r)")) {
  const marker = "  function render(rows) {";
  const helper = [
    "  function renderGuidance(r) {",
    "    const g = r && r.guidance;",
    "    if (!g) return \"\";",
    "    const classification = g.classification || \"guidance\";",
    "    const outcome = g.outcome || \"\";",
    "    const explanation = g.explanation || \"\";",
    "    return `<div style=\"margin-top:6px;font-size:11px;color:#fde68a\"><strong>Guidance:</strong> ${classification}${outcome ? \" — \" + outcome : \"\"}${explanation ? `<details style=\"margin-top:3px;\"><summary style=\"cursor:pointer;\">Guidance details</summary><div style=\"color:#bfdbfe\">${explanation}</div></details>` : \"\"}</div>`;",
    "  }",
    "",
    marker
  ].join("\\n");

  if (!src.includes(marker)) throw new Error("render marker not found");
  src = src.replace(marker, helper);
}

if (!src.includes("${renderGuidance(r)}")) {
  const marker = '          ${explanation ? `<div style="margin-top:3px;font-size:11px;color:#bfdbfe"><strong>Explanation:</strong> ${explanation}</div>` : ""}';
  const replacement = marker + "\\n          ${renderGuidance(r)}";

  if (!src.includes(marker)) throw new Error("explanation marker not found");
  src = src.replace(marker, replacement);
}

fs.writeFileSync(file, src);

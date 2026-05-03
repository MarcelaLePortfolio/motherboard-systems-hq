const fs = require("fs");

const file = "public/js/phase61_recent_history_wire.js";
let src = fs.readFileSync(file, "utf8");

if (!src.includes("function renderGuidance(r)")) {
  src = src.replace(
    `  function render(rows) {`,
    `  function renderGuidance(r) {
    const g = r?.guidance;
    if (!g) return "";
    const classification = g.classification || "guidance";
    const outcome = g.outcome || "";
    const explanation = g.explanation || "";
    return \`
      <div style="margin-top:6px;font-size:11px;color:#fde68a">
        <strong>Guidance:</strong> \${classification}\${outcome ? " — " + outcome : ""}
        \${explanation ? \`<details style="margin-top:3px;"><summary style="cursor:pointer;">Guidance details</summary><div style="color:#bfdbfe">\${explanation}</div></details>\` : ""}
      </div>
    \`;
  }

  function render(rows) {`
  );
}

if (!src.includes("${renderGuidance(r)}")) {
  src = src.replace(
    `          ${explanation ? \`<div style="margin-top:3px;font-size:11px;color:#bfdbfe"><strong>Explanation:</strong> \${explanation}</div>\` : ""}
        </div>`,
    `          ${explanation ? \`<div style="margin-top:3px;font-size:11px;color:#bfdbfe"><strong>Explanation:</strong> \${explanation}</div>\` : ""}
          \${renderGuidance(r)}
        </div>`
  );
}

fs.writeFileSync(file, src);

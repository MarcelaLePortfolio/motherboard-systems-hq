const fs = require("fs");

const file = "public/js/dashboard-tasks-widget.js";
let src = fs.readFileSync(file, "utf8");

if (!src.includes("function renderGuidance(t)")) {
  src = src.replace(
    `  async function apiJson(url, opts = {}) {`,
    `  function renderGuidance(t) {
    const g = t?.guidance;
    if (!g) return "";
    return \`<div style="margin-top:4px;font-size:12px;opacity:.75"><strong>\${esc(g.classification || "guidance")}</strong>\${g.outcome ? \`: \${esc(g.outcome)}\` : ""}\${g.explanation ? \`<details><summary>details</summary><div>\${esc(g.explanation)}</div></details>\` : ""}</div>\`;
  }

  async function apiJson(url, opts = {}) {`
  );
}

if (!src.includes("${renderGuidance(t)}")) {
  src = src.replace(
    `              </div>
            \``,
    `              </div>
              \${renderGuidance(t)}
            \``
  );
}

fs.writeFileSync(file, src);

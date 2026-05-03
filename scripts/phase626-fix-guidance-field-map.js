const fs = require("fs");

const file = "public/js/dashboard-tasks-widget.js";
let src = fs.readFileSync(file, "utf8");

// ensure guidance is read from t.guidance (already) OR fallback to payload/outcome fields
if (!src.includes("const g = t?.guidance ||")) {
  src = src.replace(
    "const g = t?.guidance;",
    "const g = t?.guidance || (t?.outcome_preview || t?.explanation_preview ? { classification: 'info', outcome: t?.outcome_preview, explanation: t?.explanation_preview } : null);"
  );
}

fs.writeFileSync(file, src);

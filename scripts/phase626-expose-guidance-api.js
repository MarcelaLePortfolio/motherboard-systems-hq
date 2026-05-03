const fs = require("fs");

const file = "server/routes/api-tasks-postgres.mjs";
let src = fs.readFileSync(file, "utf8");

if (!src.includes("completed.payload AS guidance")) {
  src = src.replace(
    `        completed.payload->>'outcome_preview' AS outcome_preview,
        completed.payload->>'explanation_preview' AS explanation_preview`,
    `        completed.payload->>'outcome_preview' AS outcome_preview,
        completed.payload->>'explanation_preview' AS explanation_preview,
        completed.payload AS guidance`
  );
}

fs.writeFileSync(file, src);

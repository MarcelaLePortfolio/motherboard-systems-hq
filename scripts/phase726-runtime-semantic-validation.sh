
#!/bin/bash

set -euo pipefail

echo "Phase 726 runtime semantic validation starting..."

TASK_RESPONSE=$(curl -sS -X POST "http://localhost:3000/api/tasks/create" \

  -H "Content-Type: application/json" \

  --data-raw '{"title":"Phase 726 runtime semantic validation","task":"Create a luxury visual launch card for Moonrise Bakery customers"}')

echo ""

echo "TASK RESPONSE:"

echo "${TASK_RESPONSE}"

TASK_ID=$(node -e 'const fs=require("fs"); const raw=fs.readFileSync(0,"utf8"); const json=JSON.parse(raw); console.log(json.task_id || json.taskId || json.id || "");' <<< "${TASK_RESPONSE}")

if [ -z "${TASK_ID}" ]; then

  echo "Failed to extract TASK_ID"

  exit 1

fi

echo ""

echo "TASK_ID=${TASK_ID}"

sleep 10

TASK_JSON=$(curl -sS "http://localhost:3000/api/tasks")

echo "${TASK_JSON}" | TASK_ID="${TASK_ID}" node - <<'NODE'

const fs = require("fs");

const data = JSON.parse(fs.readFileSync(0, "utf8"));

const tasks = Array.isArray(data)

  ? data

  : (data.tasks || data.items || []);

const taskId = process.env.TASK_ID;

const match = tasks.find(

  t =>

    t.task_id === taskId ||

    t.taskId === taskId ||

    t.id === taskId

);

if (!match) {

  console.error("Runtime validation failed: task not found");

  process.exit(1);

}

const artifact = match.artifact || {};

if (!artifact.semantic_artifact) {

  console.error("Runtime validation failed: semantic_artifact missing");

  process.exit(1);

}

if (!artifact.semantic_artifact_schema) {

  console.error("Runtime validation failed: semantic_artifact_schema missing");

  process.exit(1);

}

if (artifact.semantic_artifact_validated !== true) {

  console.error("Runtime validation failed: semantic_artifact_validated not true");

  process.exit(1);

}

if (match.semantic_artifact) {

  console.error("Runtime validation failed: top-level semantic_artifact leakage detected");

  process.exit(1);

}

console.log("");

console.log("Phase 726 runtime semantic validation passed.");

console.log("");

console.log(JSON.stringify({

  task_id: taskId,

  artifact_semantic: artifact.semantic_artifact,

  artifact_schema: artifact.semantic_artifact_schema,

  artifact_validated: artifact.semantic_artifact_validated

}, null, 2));

NODE

echo ""

echo "Phase 726 runtime semantic validation completed successfully."


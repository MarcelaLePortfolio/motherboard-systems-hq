
# Phase 726 Manual Runtime Validation Protocol

## Purpose

This document defines the safe manual validation path for Phase 726 runtime semantic metadata propagation.

It replaces the failed runtime validator script corridor.

## Why This Exists

A dedicated validator script failed three consecutive times due shell/node JSON transport issues.

Per build protocol, that script corridor was reverted and must not be retried in the same form.

## Validation Principle

Use explicit terminal commands and temporary files.

Avoid piping JSON into Node scripts that also consume stdin for source code.

## Manual Runtime Validation Steps

### 1. Confirm runtime health

```bash

docker compose ps

```

Expected:

- dashboard up

- worker up

- postgres healthy

### 2. Create a validation task

```bash

curl -sS -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-raw '{"title":"Phase 726 semantic metadata manual validation","task":"Create a luxury visual launch card for Moonrise Bakery customers"}' | tee /tmp/phase726_manual_task_response.json

```

### 3. Extract task id

```bash

TASK_ID=$(node -e 'const fs=require("fs"); const json=JSON.parse(fs.readFileSync("/tmp/phase726_manual_task_response.json","utf8")); console.log(json.task_id || json.taskId || json.id || "");')

echo "$TASK_ID"

```

### 4. Allow worker completion

```bash

sleep 10

```

### 5. Save task list response

```bash

curl -sS "http://localhost:3000/api/tasks" | tee /tmp/phase726_manual_tasks.json

```

### 6. Inspect semantic metadata location

```bash

TASK_ID="$TASK_ID" node - <<'NODE'

const fs = require("fs");

const data = JSON.parse(fs.readFileSync("/tmp/phase726_manual_tasks.json", "utf8"));

const tasks = Array.isArray(data) ? data : (data.tasks || data.items || []);

const taskId = process.env.TASK_ID;

const match = tasks.find(t => t.task_id === taskId || t.taskId === taskId || t.id === taskId);

console.log(JSON.stringify({

  task_id: match?.task_id || match?.taskId || match?.id || taskId,

  status: match?.status,

  artifact_semantic_exists: Boolean(match?.artifact?.semantic_artifact),

  artifact_semantic_schema: match?.artifact?.semantic_artifact_schema || null,

  artifact_semantic_validated: match?.artifact?.semantic_artifact_validated || null,

  top_level_semantic_exists: Boolean(match?.semantic_artifact)

}, null, 2));

NODE

```

Expected:

- `artifact_semantic_exists: true`

- `artifact_semantic_schema: semantic-artifact.v1`

- `artifact_semantic_validated: true`

- `top_level_semantic_exists: false`

### 7. Confirm artifact preview remains compatible

```bash

curl -sS "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" | tee /tmp/phase726_manual_artifact_preview.json

```

Expected:

- response is ok

- markdown content is returned

- preview route does not require semantic metadata

## Safe Conclusion Criteria

Phase 726 runtime semantic metadata propagation is considered valid when:

- semantic metadata exists inside `artifact`

- semantic metadata does not appear at top-level task payload

- artifact preview route still returns markdown content

- dashboard, worker, and postgres remain healthy

- semantic helper suite still passes

## Guardrail

Do not recreate the failed validator script pattern.

Future automation must use file-based JSON handoff or a dedicated Node script file, not stdin-mixed shell heredocs.


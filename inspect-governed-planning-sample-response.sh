
#!/usr/bin/env bash

set -euo pipefail

REPORT="governed-planning-sample-response-summary.txt"

RAW="governed-planning-sample-response.raw.json"

URL="http://localhost:8080/api/governed-planning/dry-run"

PAYLOAD='{

  "actor": "Matilda",

  "target": "Cade",

  "objective": "Inspect governed planning preview bridge without executing work",

  "scope_constraints": "Read-only planning preview bridge inspection. No mutation, no shell execution, no autonomous execution.",

  "risk_level": "low"

}'

curl -sS \

  --header "Content-Type: application/json" \

  --request POST \

  --data "$PAYLOAD" \

  "$URL" > "$RAW"

node << 'NODE' | tee "$REPORT"

const fs = require("fs");

const raw = JSON.parse(fs.readFileSync("governed-planning-sample-response.raw.json", "utf8"));

const bundle = raw.bundle || {};

const summary = {

  ok: raw.ok,

  route: raw.route,

  mode: raw.mode,

  task_recorded: raw.task_recorded,

  top_level_keys: Object.keys(raw),

  bundle_keys: Object.keys(bundle),

  bundle_schema: bundle.bundle_schema,

  bundle_phase: bundle.phase,

  envelope_version: bundle.envelope_version,

  response_keys: Object.keys(bundle.response || {}),

  reconciliation_keys: Object.keys(bundle.reconciliation || {}),

  audit_ledger_keys: Object.keys(bundle.audit_ledger || {}),

  execution_authority: bundle.execution_authority || null,

  recommended_ui_source_path: "response.bundle",

  recommended_read_only_fields: [

    "bundle.bundle_schema",

    "bundle.phase",

    "bundle.envelope_version",

    "bundle.response",

    "bundle.reconciliation",

    "bundle.audit_ledger",

    "bundle.execution_authority"

  ]

};

console.log(JSON.stringify(summary, null, 2));

NODE

cat > governed-planning-sample-response-finding.txt << 'NOTE'

GOVERNED PLANNING SAMPLE RESPONSE FINDING

Finding Status: INSPECTION ONLY

The governed planning route returns the reviewable planning artifact at:

response.bundle

The UI bridge should consume the bundle directly as a read-only artifact.

This finding does not authorize:

- approval implementation

- preview-confirmation implementation

- mutation

- shell execution

- autonomous execution

- task-record coupling

NOTE

git add inspect-governed-planning-sample-response.sh governed-planning-sample-response-summary.txt governed-planning-sample-response.raw.json governed-planning-sample-response-finding.txt

git commit -m "Inspect governed planning sample response"

git push


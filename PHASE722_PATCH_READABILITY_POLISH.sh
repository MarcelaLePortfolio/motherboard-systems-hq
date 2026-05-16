
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

BACKUP="checkpoints/PHASE722_PRE_READABILITY_POLISH.js"

echo "===== PHASE 722 READABILITY POLISH PATCH ====="

cp "$TARGET" "$BACKUP"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "phase722IsDuplicateSemanticText" in text:

    raise SystemExit("Phase 722 readability polish already present; aborting duplicate patch.")

anchor = '''    const semanticOperatorSummary = semanticEnvelope ? [

      semanticEnvelope.task_summary ? ["Semantic Summary", semanticEnvelope.task_summary] : null,

      Array.isArray(semanticEnvelope.actionable_outputs) && semanticEnvelope.actionable_outputs.length

        ? ["Actionable Outputs", semanticEnvelope.actionable_outputs.join("\\n")]

        : null,

      Array.isArray(semanticEnvelope.evidence_notes) && semanticEnvelope.evidence_notes.length

        ? ["Evidence Notes", semanticEnvelope.evidence_notes.join("\\n")]

        : null,

      semanticEnvelope.operator_next_steps ? ["Operator Next Steps", semanticEnvelope.operator_next_steps] : null

    ].filter(Boolean) : [];

'''

replacement = '''    function phase722NormalizeSemanticText(value) {

      return String(value || "")

        .replace(/Standard execution prepared for:/gi, "")

        .replace(/Prepared artifact for:/gi, "")

        .replace(/\\s+/g, " ")

        .trim()

        .toLowerCase();

    }

    function phase722IsDuplicateSemanticText(a, b) {

      const left = phase722NormalizeSemanticText(a);

      const right = phase722NormalizeSemanticText(b);

      return Boolean(left && right && (left === right || left.includes(right) || right.includes(left)));

    }

    const semanticOperatorSummary = semanticEnvelope ? [

      semanticEnvelope.task_summary && !phase722IsDuplicateSemanticText(semanticEnvelope.task_summary, displaySummary)

        ? ["Semantic Summary", semanticEnvelope.task_summary]

        : null,

      Array.isArray(semanticEnvelope.actionable_outputs) && semanticEnvelope.actionable_outputs.length

        ? ["Actionable Outputs", semanticEnvelope.actionable_outputs.filter((item) => !phase722IsDuplicateSemanticText(item, displayDeliverable)).join("\\n")]

        : null,

      Array.isArray(semanticEnvelope.evidence_notes) && semanticEnvelope.evidence_notes.length

        ? ["Evidence Notes", semanticEnvelope.evidence_notes.join("\\n")]

        : null,

      semanticEnvelope.operator_next_steps && !phase722IsDuplicateSemanticText(semanticEnvelope.operator_next_steps, nextSteps)

        ? ["Operator Next Steps", semanticEnvelope.operator_next_steps]

        : null

    ].filter((entry) => entry && String(entry[1] || "").trim()) : [];

'''

if anchor not in text:

    raise SystemExit("SEMANTIC SUMMARY ANCHOR NOT FOUND")

text = text.replace(anchor, replacement, 1)

text = text.replace(

    "Semantic Operator Summary",

    "Semantic Insights",

    1

)

text = text.replace(

    '''          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:22px 24px 10px 24px;">''',

    '''          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:${semanticOperatorSummary.length ? "14px" : "22px"} 24px 10px 24px;">''',

    1

)

path.write_text(text)

print("Phase 722 readability polish patch applied.")

PY

grep -n "phase722IsDuplicateSemanticText\\|Semantic Insights\\|semanticOperatorSummary.length" "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

git add PHASE722_PATCH_READABILITY_POLISH.sh checkpoints/PHASE722_PRE_READABILITY_POLISH.js public/js/phase530_visible_panels_bridge.js

git commit -m "Phase 722: polish semantic artifact readability"

git push origin phase719-artifact-visibility

git status --short

git log --oneline --decorate -8


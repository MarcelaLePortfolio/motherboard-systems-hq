
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

BACKUP="checkpoints/PHASE721_PRE_SEMANTIC_OPERATOR_SUMMARY.js"

echo "===== PHASE 721 SEMANTIC OPERATOR SUMMARY PATCH ====="

cp "$TARGET" "$BACKUP"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "const semanticOperatorSummary" in text:

    raise SystemExit("Semantic operator summary already present; aborting duplicate patch.")

anchor = '''    const enrichedSections = [

      ["Summary", displaySummary],

      ["Deliverable", displayDeliverable],

      ["Details", details],

      ["Recommendations", recommendations],

      ["Next Steps", nextSteps]

    ].filter(([, value]) => String(value || "").trim());

'''

replacement = '''    const enrichedSections = [

      ["Summary", displaySummary],

      ["Deliverable", displayDeliverable],

      ["Details", details],

      ["Recommendations", recommendations],

      ["Next Steps", nextSteps]

    ].filter(([, value]) => String(value || "").trim());

    const semanticOperatorSummary = semanticEnvelope ? [

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

if anchor not in text:

    raise SystemExit("ENRICHED SECTIONS ANCHOR NOT FOUND")

text = text.replace(anchor, replacement, 1)

anchor2 = '''          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:22px 24px 10px 24px;">

            ${enrichedSections.map(([label, value]) => `

              <section style="border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#93c5fd;font-weight:900;margin-bottom:10px;">${phase719EscapePreviewHtml(label)}</div>

                <div style="font-size:15px;line-height:1.6;color:#e0f2fe;white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

              </section>

            `).join("")}

          </div>

'''

replacement2 = '''          ${semanticOperatorSummary.length ? `

            <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:12px;padding:22px 24px 0 24px;">

              <section style="border:1px solid rgba(45,212,191,.24);border-radius:18px;background:rgba(6,78,59,.18);padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#5eead4;font-weight:900;margin-bottom:12px;">Semantic Operator Summary</div>

                <div style="display:grid;gap:10px;">

                  ${semanticOperatorSummary.map(([label, value]) => `

                    <div style="border-top:1px solid rgba(45,212,191,.16);padding-top:10px;">

                      <div style="font-size:10px;text-transform:uppercase;letter-spacing:.16em;color:#99f6e4;font-weight:900;margin-bottom:5px;">${phase719EscapePreviewHtml(label)}</div>

                      <div style="font-size:14px;line-height:1.55;color:#ccfbf1;white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

                    </div>

                  `).join("")}

                </div>

              </section>

            </div>

          ` : ""}

          <div style="display:grid;grid-template-columns:minmax(0,1fr);gap:14px;padding:22px 24px 10px 24px;">

            ${enrichedSections.map(([label, value]) => `

              <section style="border:1px solid rgba(96,165,250,.22);border-radius:18px;background:rgba(15,23,42,.7);padding:18px;">

                <div style="font-size:11px;text-transform:uppercase;letter-spacing:.18em;color:#93c5fd;font-weight:900;margin-bottom:10px;">${phase719EscapePreviewHtml(label)}</div>

                <div style="font-size:15px;line-height:1.6;color:#e0f2fe;white-space:pre-wrap;">${phase719EscapePreviewHtml(value)}</div>

              </section>

            `).join("")}

          </div>

'''

if anchor2 not in text:

    raise SystemExit("RENDER INSERT ANCHOR NOT FOUND")

text = text.replace(anchor2, replacement2, 1)

path.write_text(text)

print("Semantic operator summary patch applied.")

PY

grep -n "semanticOperatorSummary\\|Semantic Operator Summary" "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

git add PHASE721_PATCH_SEMANTIC_OPERATOR_SUMMARY.sh checkpoints/PHASE721_PRE_SEMANTIC_OPERATOR_SUMMARY.js public/js/phase530_visible_panels_bridge.js

git commit -m "Phase 721: add semantic operator summary card"

git push origin phase719-artifact-visibility

git status --short

git log --oneline --decorate -8


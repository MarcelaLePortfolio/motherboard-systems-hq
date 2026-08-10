#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT BOUNDED INVESTIGATION LIFECYCLE IEL RECONSTRUCTION ==="

REQUIRED_ANCESTOR="42b16358"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: implementation classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY AUTHORIZED STARTING SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-bounded-investigation-lifecycle-iel-reconstruction\.sh$|^ M scripts/implement-bounded-investigation-lifecycle-iel-reconstruction\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY CLASSIFIED IMPLEMENTATION CONTRACT ==="
grep -nE \
  'EXISTING_IEL_READER=listInterpretationEvidenceLedgerEntries|IEL_READER_EXTENSION=REQUIRED|PARALLEL_IEL_QUERY=PROHIBITED|REUSABLE_BOUNDED_LIFECYCLE_VALIDATOR=REQUIRED|IEL_RECONSTRUCTION=JSON_PARSE_PLUS_SHARED_VALIDATOR|CONVERSATION_CONTEXT_CHANGE=NOT_AUTHORIZED|PRIOR_LIFECYCLE_OLLAMA_CONTEXT=NOT_AUTHORIZED' \
  scripts/classify-exact-investigation-lifecycle-iel-read-model-implementation-surface.sh

echo
echo "=== PATCH SHARED BOUNDED LIFECYCLE VALIDATOR ==="
python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

start_marker = '  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =\n    null;\n\n  if (parsed.investigationLifecycle !== null) {'
end_marker = '\n\n  const durableInterpretation ='

start = text.find(start_marker)
if start == -1:
    raise SystemExit("STOP: lifecycle validation start marker not found.")

end = text.find(end_marker, start)
if end == -1:
    raise SystemExit("STOP: lifecycle validation end marker not found.")

old_block = text[start:end]

if 'export function validateMatildaInvestigationLifecycleArtifact' in text:
    raise SystemExit("STOP: shared lifecycle validator already exists.")

validator = '''export function validateMatildaInvestigationLifecycleArtifact(
  value: unknown,
  errorPrefix = "Ollama returned",
): MatildaInvestigationLifecycleArtifact {
  if (
    !value ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `${errorPrefix} malformed investigation lifecycle artifact.`,
    );
  }

  const candidate = value as Record<string, unknown>;

  const investigationIdentity =
    typeof candidate.investigationIdentity === "string"
      ? candidate.investigationIdentity.trim()
      : "";

  const governingQuestion =
    typeof candidate.governingQuestion === "string"
      ? candidate.governingQuestion.trim()
      : "";

  const lifecycleEvent = candidate.lifecycleEvent;

  const validLifecycleEvents =
    new Set<MatildaInvestigationLifecycleEvent>([
      "entered",
      "continued",
      "advanced",
      "resolved",
      "superseded",
      "abandoned",
    ]);

  if (!investigationIdentity) {
    throw new Error(
      `${errorPrefix} investigation lifecycle without investigation identity.`,
    );
  }

  if (!governingQuestion) {
    throw new Error(
      `${errorPrefix} investigation lifecycle without governing question.`,
    );
  }

  if (
    typeof lifecycleEvent !== "string" ||
    !validLifecycleEvents.has(
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    )
  ) {
    throw new Error(
      `${errorPrefix} invalid investigation lifecycle event.`,
    );
  }

  let lifecycleDetermination: string | null = null;

  if (candidate.lifecycleDetermination !== null) {
    if (typeof candidate.lifecycleDetermination !== "string") {
      throw new Error(
        `${errorPrefix} malformed investigation lifecycle determination.`,
      );
    }

    lifecycleDetermination =
      candidate.lifecycleDetermination.trim();

    if (!lifecycleDetermination) {
      throw new Error(
        `${errorPrefix} empty investigation lifecycle determination.`,
      );
    }
  }

  if (
    (lifecycleEvent === "advanced" ||
      lifecycleEvent === "resolved") &&
    !lifecycleDetermination
  ) {
    throw new Error(
      `${errorPrefix} ${lifecycleEvent} investigation lifecycle without required determination.`,
    );
  }

  return {
    investigationIdentity,
    governingQuestion,
    lifecycleEvent:
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    lifecycleDetermination,
  };
}

'''

insert_at = text.find('function parseStructuredResponse(')
if insert_at == -1:
    raise SystemExit("STOP: parseStructuredResponse declaration not found.")

text = text[:insert_at] + validator + text[insert_at:]

replacement = '''  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =
    null;

  if (parsed.investigationLifecycle !== null) {
    investigationLifecycle =
      validateMatildaInvestigationLifecycleArtifact(
        parsed.investigationLifecycle,
      );
  }'''

text = text.replace(old_block, replacement, 1)
path.write_text(text)
PY

echo
echo "=== VERIFY SHARED VALIDATOR EXTRACTION ==="
grep -n -A105 -B5 \
  'export function validateMatildaInvestigationLifecycleArtifact' \
  scripts/utils/ollamaChat.ts |
head -n 140

echo
echo "=== PATCH EXISTING IEL READER ONLY ==="
python3 <<'PY'
from pathlib import Path

path = Path("db/matilda-interpretation-runtime.ts")
text = path.read_text()

old_import = '''import type {
  MatildaInvestigationLifecycleArtifact,
} from "../scripts/utils/ollamaChat";
'''

new_import = '''import {
  validateMatildaInvestigationLifecycleArtifact,
  type MatildaInvestigationLifecycleArtifact,
} from "../scripts/utils/ollamaChat";
'''

if old_import not in text:
    raise SystemExit("STOP: expected lifecycle type import not found.")

text = text.replace(old_import, new_import, 1)

reader_start = text.find(
    "export function listInterpretationEvidenceLedgerEntries(limit = 20) {"
)
if reader_start == -1:
    raise SystemExit("STOP: existing IEL reader not found.")

reader_end = text.find("\n}", reader_start)
if reader_end == -1:
    raise SystemExit("STOP: existing IEL reader end not found.")

reader_end += 2
old_reader = text[reader_start:reader_end]

if "investigation_lifecycle_json" in old_reader:
    raise SystemExit(
        "STOP: existing IEL reader already contains lifecycle projection."
    )

new_reader = '''export type InterpretationEvidenceLedgerReadEntry = {
  entry_id: string;
  created_at: string;
  actor: string;
  project_id: string | null;
  conversation_id: string | null;
  interpretation_event: string;
  minimum_sufficient_context: string;
  supporting_raw_evidence: string;
  matilda_observation: string;
  unresolved_questions: string | null;
  lineage_references: string | null;
  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  supersession_status: string;
};

type InterpretationEvidenceLedgerStoredReadEntry = Omit<
  InterpretationEvidenceLedgerReadEntry,
  "investigationLifecycle"
> & {
  investigation_lifecycle_json: string | null;
};

function reconstructInvestigationLifecycle(
  value: string | null,
): MatildaInvestigationLifecycleArtifact | null {
  if (value === null) {
    return null;
  }

  let parsed: unknown;

  try {
    parsed = JSON.parse(value) as unknown;
  } catch {
    throw new Error(
      "Matilda IEL contains malformed investigation lifecycle JSON.",
    );
  }

  return validateMatildaInvestigationLifecycleArtifact(
    parsed,
    "Matilda IEL contains",
  );
}

export function listInterpretationEvidenceLedgerEntries(
  limit = 20,
): InterpretationEvidenceLedgerReadEntry[] {

  ensureInterpretationEvidenceLedgerTable();

  const rows = sqlite.prepare(`

    SELECT

      entry_id,

      created_at,

      actor,

      project_id,

      conversation_id,

      interpretation_event,

      minimum_sufficient_context,

      supporting_raw_evidence,

      matilda_observation,

      unresolved_questions,

      lineage_references,

      investigation_lifecycle_json,

      supersession_status

    FROM matilda_interpretation_evidence_ledger

    ORDER BY created_at DESC

    LIMIT ?

  `).all(
    Math.max(1, Math.min(Number(limit) || 20, 100)),
  ) as InterpretationEvidenceLedgerStoredReadEntry[];

  return rows.map((row) => ({
    entry_id: row.entry_id,
    created_at: row.created_at,
    actor: row.actor,
    project_id: row.project_id,
    conversation_id: row.conversation_id,
    interpretation_event: row.interpretation_event,
    minimum_sufficient_context:
      row.minimum_sufficient_context,
    supporting_raw_evidence:
      row.supporting_raw_evidence,
    matilda_observation: row.matilda_observation,
    unresolved_questions: row.unresolved_questions,
    lineage_references: row.lineage_references,
    investigationLifecycle:
      reconstructInvestigationLifecycle(
        row.investigation_lifecycle_json,
      ),
    supersession_status: row.supersession_status,
  }));

}'''

text = text[:reader_start] + new_reader + text[reader_end:]
path.write_text(text)
PY

echo
echo "=== VERIFY EXISTING IEL READER EXTENSION ==="
grep -n -A150 -B15 \
  'export type InterpretationEvidenceLedgerReadEntry' \
  db/matilda-interpretation-runtime.ts |
head -n 210

echo
echo "=== VERIFY NO PARALLEL IEL QUERY ADDED ==="
parallel="$(
  grep -R -n \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude='*.test.ts' \
    --exclude='*.sh' \
    'FROM matilda_interpretation_evidence_ledger' \
    db server scripts 2>/dev/null |
  grep -v 'db/matilda-interpretation-runtime.ts' ||
  true
)"

if [[ -n "$parallel" ]]; then
  echo "STOP: parallel IEL query detected:"
  printf '%s\n' "$parallel"
  exit 2
fi

echo "PARALLEL_IEL_QUERY_NOT_ADDED"

echo
echo "=== ADD TARGETED RECONSTRUCTION CONTRACT TEST ==="
cat > scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts <<'TEST'
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const ollamaSource = readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

const ielSource = readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test("shared bounded lifecycle validator exists", () => {
  assert.match(
    ollamaSource,
    /export function validateMatildaInvestigationLifecycleArtifact/,
  );
});

test("Ollama parser consumes shared lifecycle validator", () => {
  assert.match(
    ollamaSource,
    /validateMatildaInvestigationLifecycleArtifact\(\s*parsed\.investigationLifecycle/,
  );
});

test("IEL existing reader projects lifecycle JSON", () => {
  const reader = ielSource.slice(
    ielSource.indexOf(
      "export function listInterpretationEvidenceLedgerEntries",
    ),
  );

  assert.match(
    reader,
    /investigation_lifecycle_json/,
  );
});

test("IEL read model exposes typed lifecycle artifact", () => {
  assert.match(
    ielSource,
    /investigationLifecycle:\s*MatildaInvestigationLifecycleArtifact \| null/,
  );
});

test("IEL owns deterministic lifecycle JSON parsing", () => {
  assert.match(
    ielSource,
    /JSON\.parse\(value\)/,
  );

  assert.match(
    ielSource,
    /validateMatildaInvestigationLifecycleArtifact\(/,
  );
});

test("SQL null reconstructs as semantic null", () => {
  assert.match(
    ielSource,
    /if \(value === null\) \{\s*return null;/,
  );
});

test("malformed persisted JSON fails closed", () => {
  assert.match(
    ielSource,
    /Matilda IEL contains malformed investigation lifecycle JSON/,
  );
});

test("no lifecycle semantics are inferred from other IEL fields", () => {
  const reconstructionStart = ielSource.indexOf(
    "function reconstructInvestigationLifecycle",
  );

  const reconstructionEnd = ielSource.indexOf(
    "export function listInterpretationEvidenceLedgerEntries",
    reconstructionStart,
  );

  const reconstruction = ielSource.slice(
    reconstructionStart,
    reconstructionEnd,
  );

  assert.doesNotMatch(
    reconstruction,
    /durableInterpretation|matilda_observation|supersession_status|conversation_id|created_at/,
  );
});
TEST

echo
echo "=== TARGETED RECONSTRUCTION CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

echo
echo "=== EXISTING OLLAMA LIFECYCLE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== EXISTING IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== EXISTING TYPED WORKFLOW TRANSPORT CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== INTERPRETATION CONTEXT REGRESSION ==="
npx tsx --test \
  server/matilda-interpretation-context-runtime.test.ts

echo
echo "=== LIFECYCLE PROVIDER REGRESSION ==="
npx tsx --test \
  server/matilda-interpretation-lifecycle-provider.test.ts

echo
echo "=== CONVERSATION CONTEXT REGRESSION ==="
npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY UNAUTHORIZED RUNTIME SURFACES UNCHANGED ==="
if ! git diff --quiet -- \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-interpretation-lifecycle-provider.ts \
  server/matilda-interpretation-context-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: unauthorized production runtime surface changed."
  git diff -- \
    db/matilda-conversation-runtime.ts \
    server/matilda-chat-workflow.ts \
    server/matilda-interpretation-lifecycle-provider.ts \
    server/matilda-interpretation-context-runtime.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "UNAUTHORIZED_RUNTIME_SURFACES_UNCHANGED"

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^db/matilda-interpretation-runtime\.ts$|^scripts/validate-investigation-lifecycle-iel-reconstruction\.test\.ts$|^scripts/implement-bounded-investigation-lifecycle-iel-reconstruction\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized bounded reconstruction surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_BOUNDED_RECONSTRUCTION_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "BOUNDED_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION_IMPLEMENTED"
echo "SHARED_LIFECYCLE_VALIDATOR=IMPLEMENTED"
echo "OLLAMA_RESPONSE_VALIDATION=SHARED_VALIDATOR"
echo "IEL_READER=listInterpretationEvidenceLedgerEntries"
echo "IEL_READER_LIFECYCLE_PROJECTION=IMPLEMENTED"
echo "IEL_RECONSTRUCTION=JSON_PARSE_PLUS_SHARED_VALIDATOR"
echo "NULL_POLICY=SQL_NULL_TO_SEMANTIC_NULL"
echo "MALFORMED_JSON_POLICY=FAIL_CLOSED"
echo "PARALLEL_IEL_QUERY_NOT_ADDED"
echo "SEMANTIC_INFERENCE_NOT_ADDED"
echo "CONVERSATION_CONTEXT_CHANGE_NOT_ADDED"
echo "SELECTED_HISTORY_CHANGE_NOT_ADDED"
echo "PRIOR_LIFECYCLE_OLLAMA_CONTEXT_NOT_ADDED"
echo "CROSS_TURN_CONTINUITY_VALIDATION=DEFERRED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=VALIDATE_AND_CLASSIFY_BOUNDED_INVESTIGATION_LIFECYCLE_IEL_RECONSTRUCTION"

git add \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts \
  scripts/implement-bounded-investigation-lifecycle-iel-reconstruction.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle IEL reconstruction"
git push

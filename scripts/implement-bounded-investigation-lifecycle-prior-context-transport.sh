#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT BOUNDED INVESTIGATION LIFECYCLE PRIOR CONTEXT TRANSPORT ==="

REQUIRED_ANCESTOR="863964f8"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: prior-context implementation-readiness checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
  grep -vE '^\?\? scripts/implement-bounded-investigation-lifecycle-prior-context-transport\.sh$|^ M scripts/implement-bounded-investigation-lifecycle-prior-context-transport\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_STARTING_SURFACE_CONFIRMED"

echo
echo "=== VERIFY IMPLEMENTATION AUTHORIZATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_IMPLEMENTATION_READY|SCOPED_IEL_RETRIEVAL_EXTENSION=REQUIRED|GLOBAL_500_FILTERING=INSUFFICIENT|PRIOR_LIFECYCLE_SELECTION=NEWEST_NON_NULL_WITHIN_SCOPED_ROWS|OLLAMA_CONTEXT_EXTENSION=REQUIRED|PROMPT_BOUNDARY_EXTENSION=REQUIRED|NEXT_UNIT=IMPLEMENT_BOUNDED_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT' \
  scripts/classify-investigation-lifecycle-prior-context-implementation-readiness.sh

echo
echo "=== PROTECT UNAUTHORIZED RUNTIME SURFACES ==="
conversation_before="$(mktemp)"
conversation_context_before="$(mktemp)"
selected_history_before="$(mktemp)"

cp db/matilda-conversation-runtime.ts "$conversation_before"
cp server/matilda-conversation-context-runtime.ts "$conversation_context_before"
cp server/matilda-history-selection-runtime.ts "$selected_history_before"

cleanup() {
  rm -f \
    "$conversation_before" \
    "$conversation_context_before" \
    "$selected_history_before"
}
trap cleanup EXIT

echo
echo "=== PATCH EXISTING IEL READER WITH OPTIONAL SCOPE ==="
python3 <<'PY'
from pathlib import Path

path = Path("db/matilda-interpretation-runtime.ts")
text = path.read_text()

old = '''export function listInterpretationEvidenceLedgerEntries(
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
'''

new = '''export interface ListInterpretationEvidenceLedgerEntriesOptions {
  projectId?: string | null;
  conversationId?: string | null;
}

export function listInterpretationEvidenceLedgerEntries(
  limit = 20,
  options: ListInterpretationEvidenceLedgerEntriesOptions = {},
): InterpretationEvidenceLedgerReadEntry[] {

  ensureInterpretationEvidenceLedgerTable();

  const projectId =
    typeof options.projectId === "string" &&
    options.projectId.trim()
      ? options.projectId.trim()
      : null;

  const conversationId =
    typeof options.conversationId === "string" &&
    options.conversationId.trim()
      ? options.conversationId.trim()
      : null;

  const scopeClauses: string[] = [];
  const scopeParameters: string[] = [];

  if (projectId) {
    scopeClauses.push("project_id = ?");
    scopeParameters.push(projectId);
  }

  if (conversationId) {
    scopeClauses.push("conversation_id = ?");
    scopeParameters.push(conversationId);
  }

  const whereClause =
    scopeClauses.length > 0
      ? `WHERE ${scopeClauses.join(" AND ")}`
      : "";

  const boundedLimit =
    Math.max(1, Math.min(Number(limit) || 20, 100));

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

    ${whereClause}

    ORDER BY created_at DESC

    LIMIT ?

  `).all(
    ...scopeParameters,
    boundedLimit,
  ) as InterpretationEvidenceLedgerStoredReadEntry[];

  return rows.map((row) => ({
'''

if old not in text:
    raise SystemExit("STOP: expected existing IEL reader body was not found.")

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo
echo "=== PATCH WORKFLOW PRIOR LIFECYCLE SELECTION ==="
python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

import_old = '''import {
  createInterpretationEvidenceLedgerEntry,
  listInterpretationEvidenceLedgerEntries,
} from "../db/matilda-interpretation-runtime";
'''

import_new = '''import {
  createInterpretationEvidenceLedgerEntry,
  listInterpretationEvidenceLedgerEntries,
  type InterpretationEvidenceLedgerReadEntry,
} from "../db/matilda-interpretation-runtime";
'''

if import_old not in text:
    raise SystemExit("STOP: expected IEL import not found.")

text = text.replace(import_old, import_new, 1)

ollama_old = 'import { ollamaChat } from "../scripts/utils/ollamaChat";'

ollama_new = '''import {
  ollamaChat,
  type MatildaInvestigationLifecycleArtifact,
} from "../scripts/utils/ollamaChat";'''

if ollama_old not in text:
    raise SystemExit("STOP: expected ollamaChat import not found.")

text = text.replace(ollama_old, ollama_new, 1)

anchor = '''export class MatildaConversationWorkflowUnavailableError
  extends Error {'''

helper = '''export function selectMatildaPriorInvestigationLifecycle(
  entries: readonly InterpretationEvidenceLedgerReadEntry[],
): MatildaInvestigationLifecycleArtifact | null {
  const eligible =
    entries.find(
      (entry) => entry.investigationLifecycle !== null,
    );

  return eligible?.investigationLifecycle ?? null;
}

'''

if anchor not in text:
    raise SystemExit("STOP: workflow helper insertion anchor not found.")

text = text.replace(anchor, helper + anchor, 1)

old_retrieval = '''    const interpretationLedgerEntries =
      listInterpretationEvidenceLedgerEntries(500);

    const interpretationLifecycleEntries =
'''

new_retrieval = '''    const interpretationLedgerEntries =
      listInterpretationEvidenceLedgerEntries(500);

    const scopedLifecycleLedgerEntries =
      listInterpretationEvidenceLedgerEntries(
        100,
        {
          projectId,
          conversationId,
        },
      );

    const priorInvestigationLifecycle =
      selectMatildaPriorInvestigationLifecycle(
        scopedLifecycleLedgerEntries,
      );

    const interpretationLifecycleEntries =
'''

if old_retrieval not in text:
    raise SystemExit("STOP: expected workflow IEL retrieval seam not found.")

text = text.replace(old_retrieval, new_retrieval, 1)

old_context = '''        priorExplanationEvidenceStatus:
          priorSupportProvenance?.status,
        explicitEvidenceRequest,
'''

new_context = '''        priorExplanationEvidenceStatus:
          priorSupportProvenance?.status,
        priorInvestigationLifecycle,
        explicitEvidenceRequest,
'''

if old_context not in text:
    raise SystemExit("STOP: expected Ollama context seam not found.")

text = text.replace(old_context, new_context, 1)
path.write_text(text)
PY

echo
echo "=== PATCH OLLAMA PRIOR LIFECYCLE CONTEXT ==="
python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

context_anchor = '''  priorExplanationEvidenceStatus?:
    MatildaPriorExplanationEvidenceStatus;
  explicitEvidenceRequest?: boolean;
'''

context_replacement = '''  priorExplanationEvidenceStatus?:
    MatildaPriorExplanationEvidenceStatus;
  priorInvestigationLifecycle?:
    MatildaInvestigationLifecycleArtifact | null;
  explicitEvidenceRequest?: boolean;
'''

if context_anchor not in text:
    raise SystemExit("STOP: Ollama context insertion anchor not found.")

text = text.replace(context_anchor, context_replacement, 1)

prompt_anchor = '''    const priorExplanationEvidence =
      context.priorExplanationEvidenceStatus
'''

prompt_block = '''    const priorInvestigationLifecycleContext =
      context.priorInvestigationLifecycle
        ? [
            "",
            "Prior Matilda-authored Investigation Lifecycle state:",
            JSON.stringify(
              context.priorInvestigationLifecycle,
            ),
            "Treat this as previously authored semantic state for continuity context only.",
            "Do not treat its lifecycleEvent as the required current lifecycleEvent.",
            "Determine the current investigationLifecycle from the current user message and supplied context.",
          ]
        : [];

'''

if prompt_anchor not in text:
    raise SystemExit("STOP: prompt insertion anchor not found.")

text = text.replace(prompt_anchor, prompt_block + prompt_anchor, 1)

join_anchor = '''            ...conversationHistory,
            ...priorExplanationEvidence,
            "",
            `User: ${trimmedMessage}`,
'''

join_replacement = '''            ...conversationHistory,
            ...priorInvestigationLifecycleContext,
            ...priorExplanationEvidence,
            "",
            `User: ${trimmedMessage}`,
'''

if join_anchor not in text:
    raise SystemExit("STOP: prompt composition anchor not found.")

text = text.replace(join_anchor, join_replacement, 1)
path.write_text(text)
PY

echo
echo "=== ADD SCOPED RETRIEVAL CONTRACT TEST ==="
cat > scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts <<'TEST'
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const source = readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test("IEL reader accepts optional project and conversation scope", () => {
  assert.match(
    source,
    /export interface ListInterpretationEvidenceLedgerEntriesOptions/,
  );
  assert.match(source, /projectId\?: string \| null/);
  assert.match(source, /conversationId\?: string \| null/);
});

test("project and conversation scope are applied through SQL", () => {
  assert.match(source, /scopeClauses\.push\("project_id = \?"\)/);
  assert.match(source, /scopeClauses\.push\("conversation_id = \?"\)/);
});

test("scope occurs before ordering and limit", () => {
  const reader = source.slice(
    source.indexOf(
      "export function listInterpretationEvidenceLedgerEntries",
    ),
  );

  const whereIndex = reader.indexOf("${whereClause}");
  const orderIndex = reader.indexOf("ORDER BY created_at DESC");
  const limitIndex = reader.indexOf("LIMIT ?");

  assert.ok(whereIndex >= 0);
  assert.ok(orderIndex > whereIndex);
  assert.ok(limitIndex > orderIndex);
});

test("reader remains bounded", () => {
  assert.match(
    source,
    /Math\.max\(1, Math\.min\(Number\(limit\) \|\| 20, 100\)\)/,
  );
});
TEST

echo
echo "=== ADD PRIOR CONTEXT TRANSPORT CONTRACT TEST ==="
cat > scripts/validate-investigation-lifecycle-prior-context-transport.test.ts <<'TEST'
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const workflow = readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

const ollama = readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

test("workflow requests scoped lifecycle rows", () => {
  assert.match(
    workflow,
    /listInterpretationEvidenceLedgerEntries\(\s*100,\s*\{\s*projectId,\s*conversationId,/s,
  );
});

test("workflow selects newest non-null reconstructed lifecycle", () => {
  assert.match(
    workflow,
    /entries\.find\(\s*\(entry\) => entry\.investigationLifecycle !== null,/s,
  );
});

test("workflow transports prior lifecycle unchanged", () => {
  assert.match(
    workflow,
    /priorInvestigationLifecycle,\s*explicitEvidenceRequest/,
  );
});

test("Ollama context carries one nullable typed prior lifecycle", () => {
  assert.match(
    ollama,
    /priorInvestigationLifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
  );
});

test("prompt separates prior lifecycle from current determination", () => {
  assert.match(
    ollama,
    /Prior Matilda-authored Investigation Lifecycle state:/,
  );
  assert.match(
    ollama,
    /Do not treat its lifecycleEvent as the required current lifecycleEvent\./,
  );
  assert.match(
    ollama,
    /Determine the current investigationLifecycle from the current user message and supplied context\./,
  );
});

test("one Ollama invocation remains", () => {
  assert.equal(
    (ollama.match(/fetch\(/g) || []).length,
    1,
  );
});
TEST

echo
echo "=== TARGETED VALIDATION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

npx tsx --test \
  server/matilda-history-selection-runtime.test.ts

npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PROTECTED SURFACES UNCHANGED ==="
cmp -s "$conversation_before" db/matilda-conversation-runtime.ts || {
  echo "STOP: conversation-turn persistence changed."
  exit 2
}

cmp -s "$conversation_context_before" server/matilda-conversation-context-runtime.ts || {
  echo "STOP: Conversation Context Runtime changed."
  exit 2
}

cmp -s "$selected_history_before" server/matilda-history-selection-runtime.ts || {
  echo "STOP: selectedHistory runtime changed."
  exit 2
}

echo "PROTECTED_SURFACES_UNCHANGED"

echo
echo "=== VERIFY NO DATABASE SCHEMA CHANGE ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*(CREATE TABLE|ALTER TABLE|ADD COLUMN)'
then
  echo "STOP: unauthorized database schema change detected."
  exit 2
fi

echo "DATABASE_SCHEMA_UNCHANGED"

echo
echo "=== VERIFY NO PARALLEL IEL QUERY ==="
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
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^server/matilda-chat-workflow\.ts$|^scripts/utils/ollamaChat\.ts$|^scripts/validate-investigation-lifecycle-scoped-iel-retrieval\.test\.ts$|^scripts/validate-investigation-lifecycle-prior-context-transport\.test\.ts$|^scripts/implement-bounded-investigation-lifecycle-prior-context-transport\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized prior-context implementation surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_PRIOR_CONTEXT_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "BOUNDED_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT_IMPLEMENTED"
echo "SCOPED_IEL_RETRIEVAL=IMPLEMENTED"
echo "PRIOR_LIFECYCLE_SELECTION=NEWEST_NON_NULL_WITHIN_SCOPED_ROWS"
echo "WORKFLOW_ROLE=DETERMINISTIC_SELECTION_AND_TYPED_TRANSPORT"
echo "OLLAMA_PRIOR_LIFECYCLE_CONTEXT=IMPLEMENTED"
echo "PROMPT_BOUNDARY_SEPARATION=IMPLEMENTED"
echo "MATILDA_CURRENT_LIFECYCLE_AUTHORITY=PRESERVED"
echo "SELECTED_HISTORY_CHANGE=NONE"
echo "CONVERSATION_CONTEXT_RUNTIME_CHANGE=NONE"
echo "DATABASE_SCHEMA_CHANGE=NONE"
echo "PARALLEL_IEL_QUERY=NONE"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "CROSS_TURN_TRANSITION_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=VALIDATE_AND_CLASSIFY_INVESTIGATION_LIFECYCLE_PRIOR_CONTEXT_TRANSPORT"

git add \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/utils/ollamaChat.ts \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts \
  scripts/implement-bounded-investigation-lifecycle-prior-context-transport.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle prior context transport"
git push

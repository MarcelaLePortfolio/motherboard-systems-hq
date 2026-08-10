#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT INVESTIGATION LIFECYCLE TYPED IEL ADAPTER AND WORKFLOW TRANSPORT ==="

REQUIRED_ANCESTOR="88c4c8cd"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: transport-boundary classification checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$|^ M scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_IMPLEMENTATION_SCRIPT_ONLY"

echo
echo "=== VERIFY IMPLEMENTATION READINESS ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_TRANSPORT_BOUNDARY=IEL_OWNS_PERSISTENCE_SERIALIZATION|INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_IMPLEMENTATION_READY|NEXT_UNIT=IMPLEMENT_INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_AND_WORKFLOW_TRANSPORT' \
  scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary.sh

echo
echo "=== CAPTURE PROTECTED FILE BASELINES ==="
ollama_before="$(mktemp)"
conversation_before="$(mktemp)"
context_before="$(mktemp)"

cp scripts/utils/ollamaChat.ts "$ollama_before"
cp db/matilda-conversation-runtime.ts "$conversation_before"
cp server/matilda-conversation-context-runtime.ts "$context_before"

cleanup() {
  rm -f \
    "$ollama_before" \
    "$conversation_before" \
    "$context_before"
}
trap cleanup EXIT

echo
echo "=== PATCH TYPED IEL ADAPTER ==="
python3 <<'PY'
from pathlib import Path

path = Path("db/matilda-interpretation-runtime.ts")
text = path.read_text()

type_import = '''import type {
  MatildaInvestigationLifecycleArtifact,
} from "../scripts/utils/ollamaChat";
'''

if "MatildaInvestigationLifecycleArtifact" not in text:
    text = type_import + text

old_input = "  investigation_lifecycle_json?: string | null;"

new_input = (
    "  investigation_lifecycle?: "
    "MatildaInvestigationLifecycleArtifact | null;"
)

if old_input not in text:
    raise SystemExit(
        "STOP: expected raw IEL lifecycle input boundary was not found."
    )

text = text.replace(
    old_input,
    new_input,
    1,
)

old_mapping = '''    investigation_lifecycle_json:
      input.investigation_lifecycle_json ?? null,
'''

new_mapping = '''    investigation_lifecycle_json:
      input.investigation_lifecycle === null ||
      input.investigation_lifecycle === undefined
        ? null
        : JSON.stringify(
            input.investigation_lifecycle,
          ),
'''

if old_mapping not in text:
    raise SystemExit(
        "STOP: expected raw IEL lifecycle SQL mapping was not found."
    )

text = text.replace(
    old_mapping,
    new_mapping,
    1,
)

path.write_text(text)
PY

echo
echo "=== PATCH WORKFLOW DIRECT TRANSPORT ==="
python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

anchor = '''      supersession_status: "current",
    });'''

replacement = '''      supersession_status: "current",
      investigation_lifecycle:
        ollamaResult.investigationLifecycle,
    });'''

if anchor not in text:
    raise SystemExit(
        "STOP: existing IEL workflow write anchor was not found."
    )

if "investigation_lifecycle:" in text:
    raise SystemExit(
        "STOP: workflow lifecycle transport already exists."
    )

text = text.replace(
    anchor,
    replacement,
    1,
)

path.write_text(text)
PY

echo
echo "=== CREATE NARROW TRANSPORT CONTRACT TEST ==="
cat > scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts <<'EOF_TS'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const ielSource = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

const workflowSource = fs.readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

test(
  "IEL accepts typed Investigation Lifecycle artifact",
  () => {
    assert.match(
      ielSource,
      /investigation_lifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
    );

    assert.doesNotMatch(
      ielSource,
      /investigation_lifecycle_json\?: string \| null;/,
    );
  },
);

test(
  "IEL owns lifecycle JSON serialization",
  () => {
    assert.match(
      ielSource,
      /investigation_lifecycle_json:\s*[\s\S]*input\.investigation_lifecycle[\s\S]*JSON\.stringify/,
    );
  },
);

test(
  "null lifecycle remains SQL null",
  () => {
    assert.match(
      ielSource,
      /input\.investigation_lifecycle === null[\s\S]*\? null/,
    );
  },
);

test(
  "workflow directly transports Matilda-authored lifecycle artifact",
  () => {
    assert.match(
      workflowSource,
      /investigation_lifecycle:\s*[\r\n ]*ollamaResult\.investigationLifecycle/,
    );
  },
);

test(
  "workflow does not serialize lifecycle JSON",
  () => {
    assert.doesNotMatch(
      workflowSource,
      /JSON\.stringify\(\s*ollamaResult\.investigationLifecycle/,
    );

    assert.doesNotMatch(
      workflowSource,
      /investigation_lifecycle_json/,
    );
  },
);

test(
  "workflow retains one IEL write call",
  () => {
    const matches =
      workflowSource.match(
        /createInterpretationEvidenceLedgerEntry\(/g,
      ) || [];

    assert.equal(matches.length, 1);
  },
);

test(
  "conversation-turn persistence remains lifecycle-independent",
  () => {
    const conversationRuntime = fs.readFileSync(
      "db/matilda-conversation-runtime.ts",
      "utf8",
    );

    assert.doesNotMatch(
      conversationRuntime,
      /investigationLifecycle|investigation_lifecycle/,
    );
  },
);

test(
  "Conversation Context Runtime remains lifecycle-independent",
  () => {
    const contextRuntime = fs.readFileSync(
      "server/matilda-conversation-context-runtime.ts",
      "utf8",
    );

    assert.doesNotMatch(
      contextRuntime,
      /investigationLifecycle|investigation_lifecycle/,
    );
  },
);
EOF_TS

echo
echo "=== TARGETED TRANSPORT CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== EXISTING IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== INVESTIGATION LIFECYCLE RESPONSE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== LINEAGE / CONTEXT REGRESSION ==="
npx tsx --test db/matilda-conversation-lineage.test.ts
npx tsx --test server/matilda-interpretation-lifecycle-provider.test.ts
npx tsx --test server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PROTECTED RUNTIME UNCHANGED ==="
cmp -s \
  "$ollama_before" \
  scripts/utils/ollamaChat.ts || {
    echo "STOP: Ollama generation runtime changed."
    exit 2
  }

cmp -s \
  "$conversation_before" \
  db/matilda-conversation-runtime.ts || {
    echo "STOP: conversation-turn persistence changed."
    exit 2
  }

cmp -s \
  "$context_before" \
  server/matilda-conversation-context-runtime.ts || {
    echo "STOP: Conversation Context Runtime changed."
    exit 2
  }

echo "PROTECTED_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY IEL SCHEMA UNCHANGED ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*(ALTER TABLE|ADD COLUMN|CREATE TABLE)' |
  grep -q 'investigation'
then
  echo "STOP: unauthorized schema change detected."
  exit 2
fi

echo "DATABASE_SCHEMA_UNCHANGED"

echo
echo "=== VERIFY NO HISTORICAL BACKFILL ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*UPDATE .*matilda_interpretation_evidence_ledger' |
  grep -q 'investigation'
then
  echo "STOP: unauthorized lifecycle backfill detected."
  exit 2
fi

echo "HISTORICAL_ROWS_REMAIN_NULL_NO_BACKFILL"

echo
echo "=== VERIFY WORKFLOW DOES NOT INSPECT LIFECYCLE FIELDS ==="
workflow_diff="$(
  git diff -- server/matilda-chat-workflow.ts
)"

if printf '%s\n' "$workflow_diff" |
  grep -E '^\+.*(investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination)'
then
  echo "STOP: workflow is inspecting lifecycle semantic fields."
  exit 2
fi

echo "WORKFLOW_DIRECT_TRANSPORT_ONLY_CONFIRMED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^server/matilda-chat-workflow\.ts$|^scripts/validate-investigation-lifecycle-typed-iel-workflow-transport\.test\.ts$|^scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside authorized implementation surface changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "AUTHORIZED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_IMPLEMENTED"
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_IMPLEMENTED"
echo "WORKFLOW_ROLE=DIRECT_TYPED_ARTIFACT_TRANSPORT"
echo "IEL_ROLE=DETERMINISTIC_PERSISTENCE_SERIALIZATION"
echo "NULL_LIFECYCLE=SQL_NULL"
echo "DATABASE_SCHEMA_CHANGE=NONE"
echo "HISTORICAL_BACKFILL=NONE"
echo "CONVERSATION_TURN_PERSISTENCE_UNCHANGED"
echo "LIVING_DRAFT_BEHAVIOR_UNCHANGED"
echo "CONVERSATION_CONTEXT_RUNTIME_UNCHANGED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "CROSS_TURN_TRANSITION_VALIDATION=DEFERRED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_IMPLEMENTATION"

git add \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts \
  scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport.sh

git diff --cached --check
git commit -m "Implement Investigation Lifecycle workflow transport"
git push

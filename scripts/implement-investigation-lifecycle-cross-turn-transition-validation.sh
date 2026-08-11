#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT INVESTIGATION LIFECYCLE CROSS-TURN TRANSITION VALIDATION ==="

REQUIRED_ANCESTOR="70d57f41"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: implementation-readiness checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY AUTHORIZED IMPLEMENTATION SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-investigation-lifecycle-cross-turn-transition-validation\.sh$|^ M scripts/implement-investigation-lifecycle-cross-turn-transition-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== VERIFY IMPLEMENTATION AUTHORIZATION BOUNDARY ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION_READY|IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY|VALIDATION_OWNER=DEDICATED_DETERMINISTIC_VALIDATOR_IN_OLLAMA_ADAPTER|VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING|FAILURE_BEHAVIOR=FAIL_CLOSED|GOVERNING_QUESTION_EXACT_EQUALITY=NOT_AUTHORIZED|FULL_TRANSITION_MATRIX=NOT_AUTHORIZED|TERMINAL_STATE_VALIDATION=NOT_AUTHORIZED|AUTOMATIC_REPAIR=NOT_AUTHORIZED' \
  scripts/classify-investigation-lifecycle-cross-turn-transition-validation-implementation-readiness.sh

echo
echo "=== APPLY BOUNDED RUNTIME IMPLEMENTATION ==="
python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

validator_anchor = '''  return {
    investigationIdentity,
    governingQuestion,
    lifecycleEvent:
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    lifecycleDetermination,
  };
}

function parseStructuredResponse(
'''

validator_replacement = '''  return {
    investigationIdentity,
    governingQuestion,
    lifecycleEvent:
      lifecycleEvent as MatildaInvestigationLifecycleEvent,
    lifecycleDetermination,
  };
}

export function validateMatildaInvestigationLifecycleContinuity(
  priorInvestigationLifecycle:
    MatildaInvestigationLifecycleArtifact | null,
  currentInvestigationLifecycle:
    MatildaInvestigationLifecycleArtifact | null,
): void {
  if (
    !priorInvestigationLifecycle ||
    !currentInvestigationLifecycle
  ) {
    return;
  }

  if (
    currentInvestigationLifecycle.lifecycleEvent !==
      "continued" &&
    currentInvestigationLifecycle.lifecycleEvent !==
      "advanced"
  ) {
    return;
  }

  if (
    currentInvestigationLifecycle.investigationIdentity !==
    priorInvestigationLifecycle.investigationIdentity
  ) {
    throw new Error(
      `Ollama returned ${currentInvestigationLifecycle.lifecycleEvent} investigation lifecycle with investigation identity that does not match prior lifecycle context.`,
    );
  }
}

function parseStructuredResponse(
'''

if "export function validateMatildaInvestigationLifecycleContinuity(" in text:
    raise SystemExit("STOP: cross-turn continuity validator already exists.")

if validator_anchor not in text:
    raise SystemExit("STOP: shared lifecycle-validator insertion anchor not found.")

text = text.replace(
    validator_anchor,
    validator_replacement,
    1,
)

parse_anchor = '''    const result =
      parseStructuredResponse(rawResponse);

    const suppliedSegmentCandidates =
'''

parse_replacement = '''    const result =
      parseStructuredResponse(rawResponse);

    validateMatildaInvestigationLifecycleContinuity(
      context.priorInvestigationLifecycle ?? null,
      result.investigationLifecycle,
    );

    const suppliedSegmentCandidates =
'''

if parse_anchor not in text:
    raise SystemExit("STOP: post-parse continuity-validation insertion anchor not found.")

text = text.replace(
    parse_anchor,
    parse_replacement,
    1,
)

path.write_text(text)
PY

echo
echo "=== REPLACE LIFECYCLE CONTRACT TEST WITH BOUNDED CONTINUITY COVERAGE ==="
cat > scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts <<'TESTEOF'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

import {
  validateMatildaInvestigationLifecycleContinuity,
  type MatildaInvestigationLifecycleArtifact,
  type MatildaInvestigationLifecycleEvent,
} from "./ollamaChat";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

function lifecycle(
  lifecycleEvent: MatildaInvestigationLifecycleEvent,
  investigationIdentity = "investigation-alpha",
): MatildaInvestigationLifecycleArtifact {
  return {
    investigationIdentity,
    governingQuestion:
      "What repository-supported boundary governs this investigation?",
    lifecycleEvent,
    lifecycleDetermination:
      lifecycleEvent === "advanced" ||
      lifecycleEvent === "resolved"
        ? "A material investigation determination was established."
        : null,
  };
}

test(
  "Investigation Lifecycle is a required nullable structured artifact",
  () => {
    assert.match(source, /"investigationLifecycle",/);
    assert.match(
      source,
      /investigationLifecycle:\s*\{\s*anyOf:/s,
    );
    assert.match(source, /type:\s*"null"/);
    assert.match(
      source,
      /structured response without investigation lifecycle/,
    );
  },
);

test(
  "Investigation Lifecycle uses the bounded event vocabulary",
  () => {
    for (const event of [
      "entered",
      "continued",
      "advanced",
      "resolved",
      "superseded",
      "abandoned",
    ]) {
      assert.match(source, new RegExp(`"${event}"`));
    }
  },
);

test(
  "Investigation Lifecycle validates semantic identity and governing question",
  () => {
    assert.match(source, /without investigation identity/);
    assert.match(source, /without governing question/);
  },
);

test(
  "advanced and resolved require a lifecycle determination",
  () => {
    assert.match(source, /lifecycleEvent === "advanced"/);
    assert.match(source, /lifecycleEvent === "resolved"/);
    assert.match(source, /without required determination/);
  },
);

test(
  "ordinary conversation is instructed to return null lifecycle",
  () => {
    assert.match(
      source,
      /Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation\./,
    );
  },
);

test(
  "lifecycle identity is not derived from conversation storage identity",
  () => {
    assert.match(
      source,
      /Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist\./,
    );
  },
);

test("null prior and null current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      null,
      null,
    ),
  );
});

test("null prior and entered current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      null,
      lifecycle("entered"),
    ),
  );
});

test("prior lifecycle and null current are accepted", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued"),
      null,
    ),
  );
});

test("continued preserves prior investigation identity", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued", "investigation-alpha"),
      lifecycle("continued", "investigation-alpha"),
    ),
  );

  assert.throws(
    () =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle("continued", "investigation-beta"),
      ),
    /continued investigation lifecycle with investigation identity that does not match prior lifecycle context/,
  );
});

test("advanced preserves prior investigation identity", () => {
  assert.doesNotThrow(() =>
    validateMatildaInvestigationLifecycleContinuity(
      lifecycle("continued", "investigation-alpha"),
      lifecycle("advanced", "investigation-alpha"),
    ),
  );

  assert.throws(
    () =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle("advanced", "investigation-beta"),
      ),
    /advanced investigation lifecycle with investigation identity that does not match prior lifecycle context/,
  );
});

for (const event of [
  "entered",
  "resolved",
  "superseded",
  "abandoned",
] as const) {
  test(`${event} does not inherit an unauthorized identity transition rule`, () => {
    assert.doesNotThrow(() =>
      validateMatildaInvestigationLifecycleContinuity(
        lifecycle("continued", "investigation-alpha"),
        lifecycle(event, "investigation-beta"),
      ),
    );
  });
}

test(
  "cross-turn validator is invoked after structured response parsing",
  () => {
    assert.match(
      source,
      /const result =\s*parseStructuredResponse\(rawResponse\);\s*validateMatildaInvestigationLifecycleContinuity\(\s*context\.priorInvestigationLifecycle \?\? null,\s*result\.investigationLifecycle,\s*\);/s,
    );
  },
);
TESTEOF

echo
echo "=== EXTEND PERMANENT RESPONSE CONTRACT GUARD ==="
python3 - <<'PY'
from pathlib import Path

path = Path("scripts/guard-ollama-response-contract.sh")
text = path.read_text()

anchor = """grep -q 'without required determination' scripts/utils/ollamaChat.ts

echo "PASS: bounded Investigation Lifecycle structured response contract remains intact."
"""

replacement = """grep -q 'without required determination' scripts/utils/ollamaChat.ts
grep -q 'validateMatildaInvestigationLifecycleContinuity' scripts/utils/ollamaChat.ts
grep -q 'context.priorInvestigationLifecycle ?? null' scripts/utils/ollamaChat.ts
grep -q 'investigation identity that does not match prior lifecycle context' scripts/utils/ollamaChat.ts

echo "PASS: bounded Investigation Lifecycle structured response contract remains intact."
"""

if anchor not in text:
    raise SystemExit("STOP: response-contract guard lifecycle anchor not found.")

text = text.replace(anchor, replacement, 1)

echo_anchor = """echo "  ✓ fail-closed lifecycle validation"
echo "  ✓ advanced/resolved determination requirement"
echo "  ✓ one existing semantic-generation seam preserved"
"""

echo_replacement = """echo "  ✓ fail-closed lifecycle validation"
echo "  ✓ advanced/resolved determination requirement"
echo "  ✓ continued/advanced cross-turn identity continuity validation"
echo "  ✓ prior/current lifecycle comparison occurs in the existing semantic-generation seam"
echo "  ✓ one existing semantic-generation seam preserved"
"""

if echo_anchor not in text:
    raise SystemExit("STOP: response-contract guard lifecycle status anchor not found.")

text = text.replace(
    echo_anchor,
    echo_replacement,
    1,
)

path.write_text(text)
PY

echo
echo "=== VERIFY NO UNAUTHORIZED GOVERNING-QUESTION RULE ==="
if grep -nE \
  'currentInvestigationLifecycle\.governingQuestion.*priorInvestigationLifecycle\.governingQuestion|priorInvestigationLifecycle\.governingQuestion.*currentInvestigationLifecycle\.governingQuestion' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: unauthorized governingQuestion equality validation was introduced."
  exit 2
fi
echo "GOVERNING_QUESTION_EXACT_EQUALITY_NOT_IMPLEMENTED"

echo
echo "=== VERIFY NO FULL TRANSITION MATRIX ==="
if grep -nE \
  'allowedTransitions|transitionMatrix|validTransitions|terminalEvents|terminalStates' \
  scripts/utils/ollamaChat.ts
then
  echo "STOP: unauthorized transition-matrix or terminal-state machinery was introduced."
  exit 2
fi
echo "FULL_TRANSITION_MATRIX_NOT_IMPLEMENTED"

echo
echo "=== TARGETED LIFECYCLE CONTRACT TEST ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== PRIOR CONTEXT TRANSPORT REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-prior-context-transport.test.ts

echo
echo "=== SCOPED IEL RETRIEVAL REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-scoped-iel-retrieval.test.ts

echo
echo "=== IEL RECONSTRUCTION REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-reconstruction.test.ts

echo
echo "=== TYPED IEL WORKFLOW TRANSPORT REGRESSION ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== PERMANENT RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY UNAUTHORIZED SURFACES UNCHANGED ==="
if ! git diff --quiet -- \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: implementation escaped the authorized surface."
  exit 2
fi

echo "UNAUTHORIZED_SURFACES_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "BOUNDED_INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTED"
echo "IMPLEMENTATION_SCOPE=CONTINUED_AND_ADVANCED_INVESTIGATION_IDENTITY_CONTINUITY"
echo "VALIDATION_SEAM=POST_PARSE_PRE_DOWNSTREAM_PROCESSING"
echo "FAILURE_BEHAVIOR=FAIL_CLOSED"
echo "GOVERNING_QUESTION_EXACT_EQUALITY=NOT_IMPLEMENTED"
echo "FULL_TRANSITION_MATRIX=NOT_IMPLEMENTED"
echo "TERMINAL_STATE_VALIDATION=NOT_IMPLEMENTED"
echo "AUTOMATIC_REPAIR=NOT_IMPLEMENTED"
echo "SECOND_MODEL_INVOCATION=NONE"
echo "WORKFLOW_CHANGE=NONE"
echo "IEL_CHANGE=NONE"
echo "CONVERSATION_CONTEXT_RUNTIME_CHANGE=NONE"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=VALIDATE_AND_CLASSIFY_CROSS_TURN_TRANSITION_VALIDATION_IMPLEMENTATION"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/guard-ollama-response-contract.sh \
  scripts/implement-investigation-lifecycle-cross-turn-transition-validation.sh

git diff --cached --check
git commit -m "Implement bounded Investigation Lifecycle transition validation"
git push

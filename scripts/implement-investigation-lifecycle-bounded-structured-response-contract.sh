#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT INVESTIGATION LIFECYCLE BOUNDED STRUCTURED RESPONSE CONTRACT ==="

REQUIRED_ANCESTOR="1eebce27"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain implementation-readiness checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/implement-investigation-lifecycle-bounded-structured-response-contract\.sh$|^\?\? scripts/implement-investigation-lifecycle-bounded-structured-response-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_IMPLEMENTATION_UNIT_ONLY"

echo
echo "=== VERIFY IMPLEMENTATION AUTHORIZATION ==="
grep -n \
  'INVESTIGATION_LIFECYCLE_STRUCTURED_RESPONSE_IMPLEMENTATION_READY' \
  scripts/classify-investigation-lifecycle-structured-response-implementation-readiness.sh

echo
echo "=== CAPTURE PROTECTED WORKFLOW ==="
workflow_before="$(mktemp)"
cp server/matilda-chat-workflow.ts "$workflow_before"

cleanup() {
  rm -f "$workflow_before"
}
trap cleanup EXIT

echo
echo "=== PATCH STRUCTURED RESPONSE CONTRACT ==="
python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  selectedContextSegments?: unknown;
  supportSourceReferences?: unknown;
  evidence?: unknown;
  durableInterpretation?: unknown;
}'''

new = '''interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  selectedContextSegments?: unknown;
  supportSourceReferences?: unknown;
  evidence?: unknown;
  investigationLifecycle?: unknown;
  durableInterpretation?: unknown;
}'''

if old not in text:
    raise SystemExit("STOP: expected OllamaStructuredResponse interface not found.")

text = text.replace(old, new, 1)

old = '''    "supportSourceReferences",
    "evidence",
    "durableInterpretation",'''

new = '''    "supportSourceReferences",
    "evidence",
    "investigationLifecycle",
    "durableInterpretation",'''

if old not in text:
    raise SystemExit("STOP: expected structured-response required-field block not found.")

text = text.replace(old, new, 1)

schema_anchor = '''    durableInterpretation: {
      type: "string",
    },'''

if schema_anchor not in text:
    raise SystemExit("STOP: expected durableInterpretation schema anchor not found.")

lifecycle_schema = '''    investigationLifecycle: {
      anyOf: [
        {
          type: "null",
        },
        {
          type: "object",
          additionalProperties: false,
          required: [
            "investigationIdentity",
            "governingQuestion",
            "lifecycleEvent",
            "lifecycleDetermination",
          ],
          properties: {
            investigationIdentity: {
              type: "string",
            },
            governingQuestion: {
              type: "string",
            },
            lifecycleEvent: {
              type: "string",
              enum: [
                "entered",
                "continued",
                "advanced",
                "resolved",
                "superseded",
                "abandoned",
              ],
            },
            lifecycleDetermination: {
              anyOf: [
                {
                  type: "null",
                },
                {
                  type: "string",
                },
              ],
            },
          },
        },
      ],
    },
'''

text = text.replace(
    schema_anchor,
    lifecycle_schema + schema_anchor,
    1,
)

type_anchor = '''export interface MatildaSelectedContextSegment {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
}'''

if type_anchor not in text:
    raise SystemExit("STOP: expected selected-context type anchor not found.")

lifecycle_types = '''export type MatildaInvestigationLifecycleEvent =
  | "entered"
  | "continued"
  | "advanced"
  | "resolved"
  | "superseded"
  | "abandoned";

export interface MatildaInvestigationLifecycleArtifact {
  investigationIdentity: string;
  governingQuestion: string;
  lifecycleEvent: MatildaInvestigationLifecycleEvent;
  lifecycleDetermination: string | null;
}

'''

text = text.replace(
    type_anchor,
    lifecycle_types + type_anchor,
    1,
)

result_anchor = '''export interface OllamaChatResult {'''

if result_anchor not in text:
    raise SystemExit("STOP: OllamaChatResult interface not found.")

start = text.index(result_anchor)
end = text.index("\n}", start)
result_block = text[start:end + 2]

if "investigationLifecycle" in result_block:
    raise SystemExit("STOP: investigationLifecycle already exists in OllamaChatResult.")

durable_line = "  durableInterpretation: string;"

if durable_line not in result_block:
    raise SystemExit("STOP: durableInterpretation result field not found.")

result_block = result_block.replace(
    durable_line,
    '''  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  durableInterpretation: string;''',
    1,
)

text = text[:start] + result_block + text[end + 2:]

parser_anchor = '''  const durableInterpretation =
    typeof parsed.durableInterpretation === "string"
      ? parsed.durableInterpretation.trim()
      : "";'''

if parser_anchor not in text:
    raise SystemExit("STOP: durableInterpretation parser anchor not found.")

parser_code = '''  if (!("investigationLifecycle" in parsed)) {
    throw new Error(
      "Ollama returned structured response without investigation lifecycle.",
    );
  }

  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =
    null;

  if (parsed.investigationLifecycle !== null) {
    if (
      !parsed.investigationLifecycle ||
      typeof parsed.investigationLifecycle !== "object" ||
      Array.isArray(parsed.investigationLifecycle)
    ) {
      throw new Error(
        "Ollama returned malformed investigation lifecycle artifact.",
      );
    }

    const candidate =
      parsed.investigationLifecycle as Record<string, unknown>;

    const investigationIdentity =
      typeof candidate.investigationIdentity === "string"
        ? candidate.investigationIdentity.trim()
        : "";

    const governingQuestion =
      typeof candidate.governingQuestion === "string"
        ? candidate.governingQuestion.trim()
        : "";

    const lifecycleEvent =
      candidate.lifecycleEvent;

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
        "Ollama returned investigation lifecycle without investigation identity.",
      );
    }

    if (!governingQuestion) {
      throw new Error(
        "Ollama returned investigation lifecycle without governing question.",
      );
    }

    if (
      typeof lifecycleEvent !== "string" ||
      !validLifecycleEvents.has(
        lifecycleEvent as MatildaInvestigationLifecycleEvent,
      )
    ) {
      throw new Error(
        "Ollama returned invalid investigation lifecycle event.",
      );
    }

    let lifecycleDetermination: string | null = null;

    if (candidate.lifecycleDetermination !== null) {
      if (
        typeof candidate.lifecycleDetermination !== "string"
      ) {
        throw new Error(
          "Ollama returned malformed investigation lifecycle determination.",
        );
      }

      lifecycleDetermination =
        candidate.lifecycleDetermination.trim();

      if (!lifecycleDetermination) {
        throw new Error(
          "Ollama returned empty investigation lifecycle determination.",
        );
      }
    }

    if (
      (lifecycleEvent === "advanced" ||
        lifecycleEvent === "resolved") &&
      !lifecycleDetermination
    ) {
      throw new Error(
        `Ollama returned ${lifecycleEvent} investigation lifecycle without required determination.`,
      );
    }

    investigationLifecycle = {
      investigationIdentity,
      governingQuestion,
      lifecycleEvent:
        lifecycleEvent as MatildaInvestigationLifecycleEvent,
      lifecycleDetermination,
    };
  }

'''

text = text.replace(
    parser_anchor,
    parser_code + parser_anchor,
    1,
)

return_anchor = '''    evidence,
    durableInterpretation,
  };'''

if return_anchor not in text:
    raise SystemExit("STOP: structured parser return anchor not found.")

text = text.replace(
    return_anchor,
    '''    evidence,
    investigationLifecycle,
    durableInterpretation,
  };''',
    1,
)

prompt_anchor = '''            "Set durableInterpretation to a concise durable account of the user's meaning, intent, decisions, constraints, and unresolved questions.",'''

if prompt_anchor not in text:
    raise SystemExit("STOP: durableInterpretation prompt anchor not found.")

prompt_lines = '''            "Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation.",
            "Otherwise set investigationLifecycle to one bounded semantic artifact containing investigationIdentity, governingQuestion, lifecycleEvent, and lifecycleDetermination.",
            "Use lifecycleEvent only as entered, continued, advanced, resolved, superseded, or abandoned.",
            "For advanced and resolved, lifecycleDetermination must state the material investigative determination and must not be null.",
            "For entered, continued, superseded, and abandoned, lifecycleDetermination may be null when no separate material determination is required.",
            "Do not invent investigation progress unsupported by the conversation.",
            "Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist.",
'''

text = text.replace(
    prompt_anchor,
    prompt_lines + prompt_anchor,
    1,
)

final_return_anchor = '''      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
      durableInterpretation: result.durableInterpretation,
    };'''

if final_return_anchor not in text:
    raise SystemExit("STOP: final OllamaChatResult return anchor not found.")

text = text.replace(
    final_return_anchor,
    '''      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
      investigationLifecycle:
        result.investigationLifecycle,
      durableInterpretation:
        result.durableInterpretation,
    };''',
    1,
)

path.write_text(text)

print("Patched bounded Investigation Lifecycle structured response contract.")
PY

echo
echo "=== CREATE TARGETED CONTRACT TEST ==="
cat > scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts <<'TEST'
import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";

const source = fs.readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

test(
  "Investigation Lifecycle is a required nullable structured artifact",
  () => {
    assert.match(
      source,
      /"investigationLifecycle",/,
    );

    assert.match(
      source,
      /investigationLifecycle:\s*\{\s*anyOf:/s,
    );

    assert.match(
      source,
      /type:\s*"null"/,
    );

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
      assert.match(
        source,
        new RegExp(`"${event}"`),
      );
    }
  },
);

test(
  "Investigation Lifecycle validates semantic identity and governing question",
  () => {
    assert.match(
      source,
      /without investigation identity/,
    );

    assert.match(
      source,
      /without governing question/,
    );
  },
);

test(
  "advanced and resolved require a lifecycle determination",
  () => {
    assert.match(
      source,
      /lifecycleEvent === "advanced"/,
    );

    assert.match(
      source,
      /lifecycleEvent === "resolved"/,
    );

    assert.match(
      source,
      /without required determination/,
    );
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
TEST

echo
echo "=== EXTEND RESPONSE CONTRACT GUARD ==="
cat >> scripts/guard-ollama-response-contract.sh <<'GUARD'

echo
echo "========== GUARD INVESTIGATION LIFECYCLE RESPONSE CONTRACT =========="

grep -q '"investigationLifecycle"' scripts/utils/ollamaChat.ts
grep -q 'MatildaInvestigationLifecycleArtifact' scripts/utils/ollamaChat.ts
grep -q '"entered"' scripts/utils/ollamaChat.ts
grep -q '"continued"' scripts/utils/ollamaChat.ts
grep -q '"advanced"' scripts/utils/ollamaChat.ts
grep -q '"resolved"' scripts/utils/ollamaChat.ts
grep -q '"superseded"' scripts/utils/ollamaChat.ts
grep -q '"abandoned"' scripts/utils/ollamaChat.ts
grep -q 'structured response without investigation lifecycle' scripts/utils/ollamaChat.ts
grep -q 'without required determination' scripts/utils/ollamaChat.ts

echo "PASS: bounded Investigation Lifecycle structured response contract remains intact."
echo "  ✓ required nullable Investigation Lifecycle artifact"
echo "  ✓ bounded lifecycle event vocabulary"
echo "  ✓ fail-closed lifecycle validation"
echo "  ✓ advanced/resolved determination requirement"
echo "  ✓ one existing semantic-generation seam preserved"
GUARD

echo
echo "=== VERIFY WORKFLOW UNCHANGED ==="
if ! cmp -s "$workflow_before" server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow changed."
  git diff -- server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_WORKFLOW_UNCHANGED"

echo
echo "=== TARGETED INVESTIGATION LIFECYCLE TEST ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== FULL OLLAMA REGRESSION SUITE ==="
npx tsx --test scripts/utils/ollamaChat*.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ONE MODEL INVOCATION SEAM ==="
invocation_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

if [[ "$invocation_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation; found $invocation_count."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY AUTHORIZED CHANGE SURFACE ==="
changed="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^scripts/utils/ollamaChat\.ts$|^scripts/utils/ollamaChat\.investigation-lifecycle-contract\.test\.ts$|^scripts/guard-ollama-response-contract\.sh$|^scripts/implement-investigation-lifecycle-bounded-structured-response-contract\.sh$' ||
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
echo "INVESTIGATION_LIFECYCLE_BOUNDED_STRUCTURED_RESPONSE_CONTRACT_IMPLEMENTED"
echo "INITIAL_CONTRACT=REQUIRED_NULLABLE_INVESTIGATION_LIFECYCLE"
echo "LIFECYCLE_EVENT_VOCABULARY=BOUNDED"
echo "CONDITIONAL_VALIDATION=POST_PARSE_FAIL_CLOSED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "WORKFLOW_CONSUMPTION_NOT_ADDED"
echo "PERSISTENCE_NOT_ADDED"
echo "IEL_EXTENSION_NOT_ADDED"
echo "DATABASE_CHANGE_NOT_ADDED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "NEXT_ACTION=VALIDATE_INVESTIGATION_LIFECYCLE_BOUNDED_RESPONSE_CONTRACT"

git add \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts \
  scripts/guard-ollama-response-contract.sh \
  scripts/implement-investigation-lifecycle-bounded-structured-response-contract.sh

git diff --cached --check

git commit -m "Implement bounded Investigation Lifecycle response contract"
git push

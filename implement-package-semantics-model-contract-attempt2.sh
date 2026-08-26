#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT PACKAGE SEMANTICS MODEL CONTRACT ATTEMPT 2 ==="
echo "BASELINE_COMMIT=5921be61"
echo "AUTHORIZED_BY=ee2d2495"
echo "FAILED_IMPLEMENTATION_ATTEMPTS_BEFORE_THIS=1"
echo "SCOPE=OLLAMA_TYPED_CONTRACT_VALIDATOR_PARSER_PROMPT_AND_RESULT_TRANSPORT_ONLY"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"STOP_{label}_EXPECTED_1_FOUND_{count}")
    text = text.replace(old, new, 1)

replace_once(
'''  evidence?: unknown;
  investigationLifecycle?: unknown;
  durableInterpretation?: unknown;
''',
'''  evidence?: unknown;
  investigationLifecycle?: unknown;
  packageSemantics?: unknown;
  durableInterpretation?: unknown;
''',
"STRUCTURED_RESPONSE_FIELD",
)

replace_once(
'''    "evidence",
    "investigationLifecycle",
    "durableInterpretation",
''',
'''    "evidence",
    "investigationLifecycle",
    "packageSemantics",
    "durableInterpretation",
''',
"SCHEMA_REQUIRED_FIELD",
)

replace_once(
'''    durableInterpretation: {
      type: "string",
    },
''',
'''    packageSemantics: {
      anyOf: [
        {
          type: "null",
        },
        {
          type: "object",
          additionalProperties: false,
          required: [
            "expectedOutcome",
            "proposedWork",
            "proposedArtifacts",
            "inScope",
            "outOfScope",
            "constraints",
            "unresolvedQuestions",
          ],
          properties: {
            expectedOutcome: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedWork: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            proposedArtifacts: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            inScope: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            outOfScope: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            constraints: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
            unresolvedQuestions: {
              anyOf: [{ type: "null" }, { type: "string" }],
            },
          },
        },
      ],
    },
    durableInterpretation: {
      type: "string",
    },
''',
"SCHEMA_PROPERTY",
)

replace_once(
'''  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  durableInterpretation: string;
}

export type MatildaInvestigationLifecycleEvent =
''',
'''  investigationLifecycle: MatildaInvestigationLifecycleArtifact | null;
  packageSemantics: MatildaPackageSemanticsArtifact | null;
  durableInterpretation: string;
}

export interface MatildaPackageSemanticsArtifact {
  expectedOutcome: string | null;
  proposedWork: string | null;
  proposedArtifacts: string | null;
  inScope: string | null;
  outOfScope: string | null;
  constraints: string | null;
  unresolvedQuestions: string | null;
}

export type MatildaInvestigationLifecycleEvent =
''',
"RESULT_TYPE",
)

validator_anchor = '''export function validateMatildaInvestigationLifecycleArtifact(
'''
if text.count(validator_anchor) != 1:
    raise SystemExit(
        f"STOP_VALIDATOR_ANCHOR_EXPECTED_1_FOUND_{text.count(validator_anchor)}"
    )

package_validator = '''export function validateMatildaPackageSemanticsArtifact(
  value: unknown,
  errorPrefix = "Ollama returned",
): MatildaPackageSemanticsArtifact {
  if (
    !value ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `${errorPrefix} malformed package semantics artifact.`,
    );
  }

  const candidate = value as Record<string, unknown>;

  const fields = [
    "expectedOutcome",
    "proposedWork",
    "proposedArtifacts",
    "inScope",
    "outOfScope",
    "constraints",
    "unresolvedQuestions",
  ] as const;

  const validated: MatildaPackageSemanticsArtifact = {
    expectedOutcome: null,
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  for (const field of fields) {
    const rawValue = candidate[field];

    if (rawValue === null) {
      validated[field] = null;
      continue;
    }

    if (typeof rawValue !== "string") {
      throw new Error(
        `${errorPrefix} malformed package semantics field ${field}.`,
      );
    }

    const trimmedValue = rawValue.trim();

    if (!trimmedValue) {
      throw new Error(
        `${errorPrefix} empty package semantics field ${field}.`,
      );
    }

    validated[field] = trimmedValue;
  }

  return validated;
}

'''

text = text.replace(
    validator_anchor,
    package_validator + validator_anchor,
    1,
)

replace_once(
'''  if (!("investigationLifecycle" in parsed)) {
    throw new Error(
      "Ollama returned structured response without investigation lifecycle.",
    );
  }

  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =
''',
'''  if (!("investigationLifecycle" in parsed)) {
    throw new Error(
      "Ollama returned structured response without investigation lifecycle.",
    );
  }

  if (!("packageSemantics" in parsed)) {
    throw new Error(
      "Ollama returned structured response without package semantics.",
    );
  }

  let investigationLifecycle: MatildaInvestigationLifecycleArtifact | null =
''',
"PARSER_REQUIRED_FIELD",
)

replace_once(
'''  if (parsed.investigationLifecycle !== null) {
    investigationLifecycle =
      validateMatildaInvestigationLifecycleArtifact(
        parsed.investigationLifecycle,
      );
  }

  const durableInterpretation =
''',
'''  if (parsed.investigationLifecycle !== null) {
    investigationLifecycle =
      validateMatildaInvestigationLifecycleArtifact(
        parsed.investigationLifecycle,
      );
  }

  let packageSemantics: MatildaPackageSemanticsArtifact | null =
    null;

  if (parsed.packageSemantics !== null) {
    packageSemantics =
      validateMatildaPackageSemanticsArtifact(
        parsed.packageSemantics,
      );
  }

  const durableInterpretation =
''',
"PARSER_VALIDATION",
)

replace_once(
'''    evidence,
    investigationLifecycle,
    durableInterpretation,
  };
}

export async function ollamaChat(
''',
'''    evidence,
    investigationLifecycle,
    packageSemantics,
    durableInterpretation,
  };
}

export async function ollamaChat(
''',
"PARSED_RESULT_RETURN",
)

replace_once(
'''            "Do not invent investigation progress unsupported by the conversation.",
            "Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist.",
            "Set durableInterpretation to a concise durable account of the user's meaning, intent, decisions, constraints, and unresolved questions.",
''',
'''            "Do not invent investigation progress unsupported by the conversation.",
            "Do not use conversation identifiers or interpretation-entry identifiers as investigationIdentity merely because those identifiers exist.",
            "Set packageSemantics to null only when the current turn establishes no request-specific structured package semantics.",
            "Otherwise set packageSemantics to one atomic non-authoritative artifact describing the user's requested outcome, proposed work, proposed artifacts, scope, constraints, and unresolved questions.",
            "For expectedOutcome, proposedWork, proposedArtifacts, inScope, outOfScope, constraints, and unresolvedQuestions, use a concise non-empty string only when that semantic is actually established; otherwise use null.",
            "Do not use generic Living Draft process language as package semantics.",
            "Do not invent scope, deliverables, constraints, outcomes, or unresolved questions.",
            "Set durableInterpretation to a concise durable account of the user's meaning, intent, decisions, constraints, and unresolved questions.",
''',
"PROMPT_CONTRACT",
)

replace_once(
'''      investigationLifecycle:
        result.investigationLifecycle,
      durableInterpretation:
        result.durableInterpretation,
''',
'''      investigationLifecycle:
        result.investigationLifecycle,
      packageSemantics:
        result.packageSemantics,
      durableInterpretation:
        result.durableInterpretation,
''',
"OLLAMA_RESULT_RETURN",
)

path.write_text(text)
PY

echo
echo "=== VERIFY MODEL CONTRACT MARKERS ==="
rg -n \
  'packageSemantics|MatildaPackageSemanticsArtifact|validateMatildaPackageSemanticsArtifact|structured response without package semantics|Do not use generic Living Draft process language' \
  scripts/utils/ollamaChat.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check
git diff -- scripts/utils/ollamaChat.ts

echo
echo "MODEL_CONTRACT_ATTEMPT_2=PASS"
echo "NEXT_ACTION=COMMIT_THIS_STABLE_SUBUNIT_BEFORE_IEL_TRANSPORT_IMPLEMENTATION"

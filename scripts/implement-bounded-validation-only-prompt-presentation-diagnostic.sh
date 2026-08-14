#!/usr/bin/env bash
set -euo pipefail

echo "=== IMPLEMENT BOUNDED VALIDATION-ONLY PROMPT PRESENTATION DIAGNOSTIC ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 3c18d4df HEAD

authorization="scripts/authorize-bounded-prompt-presentation-diagnostic-implementation.sh"
ollama="scripts/utils/ollamaChat.ts"

test -f "$authorization"
test -f "$ollama"

grep -q 'DIAGNOSTIC_IMPLEMENTATION_AUTHORIZED=' "$authorization"
grep -q '^YES$' <(awk '/DIAGNOSTIC_IMPLEMENTATION_AUTHORIZED=/{getline; print}' "$authorization")
grep -q 'PRODUCTION_REMEDY_AUTHORIZED=' "$authorization"
grep -q '^NO$' <(awk '/PRODUCTION_REMEDY_AUTHORIZED=/{getline; print}' "$authorization")

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = """  validationGenerationSeed?: number;
  observeParsedSupportSourceReferences?: (
"""
new = """  validationGenerationSeed?: number;
  validationPromptPresentationVariant?:
    | "explicit_parent_child_separation";
  observeParsedSupportSourceReferences?: (
"""
if old not in text:
    raise SystemExit("STOP: OllamaChatContext insertion point not found.")
text = text.replace(old, new, 1)

old = """    const response = await fetch(
"""
new = """    const validationPromptPresentation =
      context.validationPromptPresentationVariant ===
      "explicit_parent_child_separation"
        ? [
            "",
            "Validation-only project-context identity presentation:",
            "Support provenance identities and semantic child-selection identities are separate domains.",
            "",
            "Parent support-provenance identities:",
            ...(context.projectContextExcerpts || []).flatMap((item) => [
              `Parent support source = ${item.relativePath}:${item.lineNumber}`,
            ]),
            "",
            "Child semantic-selection identities:",
            ...(context.projectContextSegmentCandidates || []).flatMap(
              (item) => [
                `Child selection source = ${item.relativePath}:${item.sourceStartLine}:${item.sourceEndLine}`,
                `Child parent support source = ${item.parentRelativePath}:${item.parentLineNumber}`,
              ],
            ),
            "",
            "When a selected child supports the reply, selectedContextSegments must use the exact child selection identity.",
            "supportSourceReferences must use only the corresponding exact parent support source identity.",
            "Never copy a child sourceStartLine or sourceEndLine into a project_context_excerpt support reference.",
            "This validation-only presentation does not change the semantic contract or the allowed source identities.",
          ]
        : [];

    const response = await fetch(
"""
if old not in text:
    raise SystemExit("STOP: response insertion point not found.")
text = text.replace(old, new, 1)

old = """            "supportSourceReferences records support provenance only. Do not use it for reasoning text, confidence, correctness, or Explanation Status.",
            "Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation.",
"""
new = """            "supportSourceReferences records support provenance only. Do not use it for reasoning text, confidence, correctness, or Explanation Status.",
            ...validationPromptPresentation,
            "Set investigationLifecycle to null when the current response does not semantically enter, continue, advance, resolve, supersede, or abandon an investigation.",
"""
if old not in text:
    raise SystemExit("STOP: prompt insertion point not found.")
text = text.replace(old, new, 1)

path.write_text(text)
PY

cat > scripts/run-bounded-prompt-presentation-diagnostic.ts << 'TS'
import { createHash } from "node:crypto";

import {
  ollamaChat,
  type OllamaChatContext,
  type MatildaSupportSourceReference,
} from "./utils/ollamaChat";

const FIXED_SEED = 424242;
const PAIR_COUNT = 10;

type Arm = "control" | "experimental";

interface Observation {
  pair: number;
  arm: Arm;
  semanticPass: boolean;
  unsupportedProjectContextReference: boolean;
  failClosedOrRuntimeRejection: boolean;
  fingerprint: string;
  error: string | null;
  parsedSupportReferences: MatildaSupportSourceReference[];
}

const baseContext: OllamaChatContext = {
  projectId: "hq",
  projectDisplayName: "Motherboard Systems HQ",
  projectContextExcerpts: [
    {
      relativePath: "docs/diagnostic-context.md",
      lineNumber: 40,
      excerpt:
        "The collaboration runtime preserves fail-closed project-context support provenance.",
      provenance: "git_tracked_project_file",
      authorityStatus: "candidate_evidence_not_authority",
    },
  ],
  projectContextSegmentCandidates: [
    {
      relativePath: "docs/diagnostic-context.md",
      parentRelativePath: "docs/diagnostic-context.md",
      parentLineNumber: 40,
      sourceStartLine: 42,
      sourceEndLine: 44,
      text:
        "Fail-closed support validation rejects project-context references not supplied in the invocation.",
    },
  ],
  history: [],
  validationGenerationSeed: FIXED_SEED,
};

const message =
  "Based only on the supplied project context, what reliability property does the collaboration runtime preserve?";

function fingerprint(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

async function run(pair: number, arm: Arm): Promise<Observation> {
  const parsedSupportReferences: MatildaSupportSourceReference[] = [];

  try {
    const result = await ollamaChat(message, {
      ...baseContext,
      ...(arm === "experimental"
        ? {
            validationPromptPresentationVariant:
              "explicit_parent_child_separation" as const,
          }
        : {}),
      observeParsedSupportSourceReferences: (references) => {
        parsedSupportReferences.push(...references);
      },
    });

    return {
      pair,
      arm,
      semanticPass: true,
      unsupportedProjectContextReference: false,
      failClosedOrRuntimeRejection: false,
      fingerprint: fingerprint(JSON.stringify(result)),
      error: null,
      parsedSupportReferences,
    };
  } catch (error) {
    const message =
      error instanceof Error ? error.message : String(error);

    return {
      pair,
      arm,
      semanticPass: false,
      unsupportedProjectContextReference:
        message.includes(
          "project-context support reference that was not supplied in this invocation",
        ),
      failClosedOrRuntimeRejection: true,
      fingerprint: fingerprint(
        JSON.stringify({
          message,
          parsedSupportReferences,
        }),
      ),
      error: message,
      parsedSupportReferences,
    };
  }
}

const observations: Observation[] = [];

for (let pair = 1; pair <= PAIR_COUNT; pair += 1) {
  observations.push(await run(pair, "control"));
  observations.push(await run(pair, "experimental"));
}

const summarize = (arm: Arm) => {
  const armObservations = observations.filter(
    (observation) => observation.arm === arm,
  );

  return {
    runs: armObservations.length,
    semanticPasses: armObservations.filter(
      (observation) => observation.semanticPass,
    ).length,
    unsupportedProjectContextReferenceFailures:
      armObservations.filter(
        (observation) =>
          observation.unsupportedProjectContextReference,
      ).length,
    failClosedOrRuntimeRejections:
      armObservations.filter(
        (observation) =>
          observation.failClosedOrRuntimeRejection,
      ).length,
    uniqueFingerprints: new Set(
      armObservations.map(
        (observation) => observation.fingerprint,
      ),
    ).size,
  };
};

const control = summarize("control");
const experimental = summarize("experimental");

console.log("DIAGNOSTIC_CLASS=VALIDATION_ONLY_NON_PRODUCTION_AB_COMPARISON");
console.log(`FIXED_SEED=${FIXED_SEED}`);
console.log(`PAIR_COUNT=${PAIR_COUNT}`);
console.log(`TOTAL_RUNS=${observations.length}`);
console.log(`CONTROL_RUNS=${control.runs}`);
console.log(`CONTROL_SEMANTIC_PASSES=${control.semanticPasses}`);
console.log(
  `CONTROL_UNSUPPLIED_SUPPORT_FAILURES=${control.unsupportedProjectContextReferenceFailures}`,
);
console.log(
  `CONTROL_FAIL_CLOSED_OR_RUNTIME_REJECTIONS=${control.failClosedOrRuntimeRejections}`,
);
console.log(
  `CONTROL_UNIQUE_FINGERPRINTS=${control.uniqueFingerprints}`,
);
console.log(`EXPERIMENTAL_RUNS=${experimental.runs}`);
console.log(
  `EXPERIMENTAL_SEMANTIC_PASSES=${experimental.semanticPasses}`,
);
console.log(
  `EXPERIMENTAL_UNSUPPLIED_SUPPORT_FAILURES=${experimental.unsupportedProjectContextReferenceFailures}`,
);
console.log(
  `EXPERIMENTAL_FAIL_CLOSED_OR_RUNTIME_REJECTIONS=${experimental.failClosedOrRuntimeRejections}`,
);
console.log(
  `EXPERIMENTAL_UNIQUE_FINGERPRINTS=${experimental.uniqueFingerprints}`,
);

for (const observation of observations) {
  console.log(
    JSON.stringify({
      pair: observation.pair,
      arm: observation.arm,
      semanticPass: observation.semanticPass,
      unsupportedProjectContextReference:
        observation.unsupportedProjectContextReference,
      fingerprint: observation.fingerprint,
      error: observation.error,
      parsedSupportReferences:
        observation.parsedSupportReferences,
    }),
  );
}

console.log("PRODUCTION_PROMPT_CHANGE=NONE");
console.log("PRODUCTION_GENERATION_POLICY_CHANGE=NONE");
console.log("VALIDATOR_CHANGE=NONE");
console.log("MODEL_CHANGE=NONE");
console.log("RETRY_OR_SECOND_MODEL_CALL=NONE");
console.log("PRODUCTION_CHANGE=NONE");
TS

echo
echo "=== VERIFY DIAGNOSTIC SEAM ==="
grep -q 'validationPromptPresentationVariant' scripts/utils/ollamaChat.ts
grep -q 'explicit_parent_child_separation' scripts/utils/ollamaChat.ts
grep -q 'Validation-only project-context identity presentation:' scripts/utils/ollamaChat.ts
grep -q 'validationPromptPresentationVariant' scripts/run-bounded-prompt-presentation-diagnostic.ts
echo "DIAGNOSTIC_SEAM=CONFIRMED"

echo
echo "=== VERIFY DEFAULT INERTNESS ==="
grep -q 'context.validationPromptPresentationVariant ===' scripts/utils/ollamaChat.ts
grep -q ': \[\];' scripts/utils/ollamaChat.ts
echo "DEFAULT_INERTNESS=CONFIRMED"

echo
echo "=== TYPECHECK / TARGETED VALIDATION ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

cat <<'MAP'
DIAGNOSTIC_IMPLEMENTATION=
COMPLETE

DIAGNOSTIC_SCOPE=
VALIDATION_ONLY

REQUEST_SCOPED_PRESENTATION_VARIANT_SELECTOR=
IMPLEMENTED

BOUNDED_AB_RUNNER=
IMPLEMENTED

PRODUCTION_DEFAULT=
UNCHANGED_WHEN_SELECTOR_ABSENT

SEMANTIC_CONTRACT=
UNCHANGED

STRUCTURED_RESPONSE_SCHEMA=
UNCHANGED

FAIL_CLOSED_VALIDATION=
UNCHANGED

MODEL=
UNCHANGED

ONE_INVOCATION_PER_RUN=
PRESERVED

RETRY=
NONE

PRODUCTION_PROMPT_CHANGE=
NONE

PRODUCTION_GENERATION_POLICY_CHANGE=
NONE

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
RUN_BOUNDED_PROMPT_PRESENTATION_DIAGNOSTIC
MAP

git diff --check

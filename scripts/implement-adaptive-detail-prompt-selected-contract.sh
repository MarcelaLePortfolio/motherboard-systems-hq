#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — IMPLEMENT PROMPT + SELECTED SEGMENTS CONTRACT ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "51185ee8" ]]; then
  echo "STOP: expected HEAD 51185ee8."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-prompt-selected-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

def replace_once(old, new, label):
    global text
    if old not in text:
        raise SystemExit(f"STOP: {label} seam not found.")
    text = text.replace(old, new, 1)

replace_once(
'''interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  supportSourceReferences?: unknown;''',
'''interface OllamaStructuredResponse {
  reply?: unknown;
  explanationStatus?: unknown;
  selectedContextSegments?: unknown;
  supportSourceReferences?: unknown;''',
"structured response",
)

replace_once(
'''    "reply",
    "explanationStatus",
    "supportSourceReferences",''',
'''    "reply",
    "explanationStatus",
    "selectedContextSegments",
    "supportSourceReferences",''',
"schema required fields",
)

replace_once(
'''    supportSourceReferences: {
      type: "array",''',
'''    selectedContextSegments: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "relativePath",
          "sourceStartLine",
          "sourceEndLine",
        ],
        properties: {
          relativePath: {
            type: "string",
          },
          sourceStartLine: {
            type: "integer",
            minimum: 1,
          },
          sourceEndLine: {
            type: "integer",
            minimum: 1,
          },
        },
      },
    },
    supportSourceReferences: {
      type: "array",''',
"selected segment schema",
)

replace_once(
'''export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  evidence: MatildaEvidenceArtifact | null;
  evidenceSufficient: boolean;
  durableInterpretation: string;
}

function parseStructuredResponse(
  rawResponse: string,
): OllamaChatResult {''',
'''export interface OllamaChatResult {
  reply: string;
  explanationStatus: MatildaExplanationStatus;
  supportSourceReferences: MatildaSupportSourceReference[];
  evidence: MatildaEvidenceArtifact | null;
  evidenceSufficient: boolean;
  durableInterpretation: string;
}

interface MatildaSelectedContextSegment {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
}

type ParsedOllamaChatResult =
  Omit<OllamaChatResult, "evidenceSufficient"> & {
    selectedContextSegments: MatildaSelectedContextSegment[];
  };

function parseStructuredResponse(
  rawResponse: string,
): ParsedOllamaChatResult {''',
"internal parsed contract",
)

replace_once(
'''  const rawSupportSourceReferences =
    Array.isArray(parsed.supportSourceReferences)
      ? parsed.supportSourceReferences
      : null;''',
'''  const rawSelectedContextSegments =
    Array.isArray(parsed.selectedContextSegments)
      ? parsed.selectedContextSegments
      : null;

  const selectedContextSegments: MatildaSelectedContextSegment[] = [];

  if (rawSelectedContextSegments) {
    for (const segment of rawSelectedContextSegments) {
      if (
        !segment ||
        typeof segment !== "object" ||
        Array.isArray(segment)
      ) {
        throw new Error(
          "Ollama returned malformed selected context segment.",
        );
      }

      const candidate = segment as Record<string, unknown>;

      if (
        typeof candidate.relativePath !== "string" ||
        !candidate.relativePath.trim() ||
        typeof candidate.sourceStartLine !== "number" ||
        !Number.isInteger(candidate.sourceStartLine) ||
        candidate.sourceStartLine < 1 ||
        typeof candidate.sourceEndLine !== "number" ||
        !Number.isInteger(candidate.sourceEndLine) ||
        candidate.sourceEndLine < candidate.sourceStartLine
      ) {
        throw new Error(
          "Ollama returned malformed selected context segment.",
        );
      }

      selectedContextSegments.push({
        relativePath: candidate.relativePath.trim(),
        sourceStartLine: candidate.sourceStartLine,
        sourceEndLine: candidate.sourceEndLine,
      });
    }
  }

  const rawSupportSourceReferences =
    Array.isArray(parsed.supportSourceReferences)
      ? parsed.supportSourceReferences
      : null;''',
"selected segment parser",
)

replace_once(
'''  if (!rawSupportSourceReferences) {
    throw new Error(
      "Ollama returned invalid support source references.",
    );
  }''',
'''  if (!rawSelectedContextSegments) {
    throw new Error(
      "Ollama returned invalid selected context segments.",
    );
  }

  if (!rawSupportSourceReferences) {
    throw new Error(
      "Ollama returned invalid support source references.",
    );
  }''',
"required selected segments validation",
)

replace_once(
'''  return {
    reply,
    explanationStatus,
    supportSourceReferences,
    evidence,
    durableInterpretation,
  };''',
'''  return {
    reply,
    explanationStatus,
    selectedContextSegments,
    supportSourceReferences,
    evidence,
    durableInterpretation,
  };''',
"parsed return",
)

replace_once(
'''    const projectContextWarning = context.projectContextWarning''',
'''    const projectContextSegmentCandidates =
      context.projectContextSegmentCandidates?.length
        ? [
            "",
            "Project-context segment candidates:",
            "These child segments are deterministic subdivisions of supplied git-tracked project-context evidence.",
            "They are candidate evidence, not authority.",
            "Select only child segments whose content materially affects the immediate reply.",
            "Parent excerpts remain the support-provenance and Evidence Composition universe.",
            ...context.projectContextSegmentCandidates.flatMap(
              (item) => [
                "",
                `Segment source: ${item.relativePath}:${item.sourceStartLine}-${item.sourceEndLine}`,
                "Authority status: candidate_evidence_not_authority",
                item.text,
              ],
            ),
          ]
        : [];

    const projectContextWarning = context.projectContextWarning''',
"candidate prompt section",
)

replace_once(
'''            "Set supportSourceReferences to only the supplied conversation turns or project-context excerpts that explicitly support the conclusion, recommendation, or assessment expressed in reply.",''',
'''            "Set selectedContextSegments to exactly the supplied project-context child segments whose content materially affects the immediate reply.",
            "Use only the exact relativePath, sourceStartLine, and sourceEndLine supplied for each selected child.",
            "Do not select a child merely because it was supplied.",
            "Return [] when no supplied project-context child materially affects the immediate reply.",
            "Conversation history remains independent and does not require selectedContextSegments membership.",
            "Set supportSourceReferences to only the supplied conversation turns or parent project-context excerpts that explicitly support the conclusion, recommendation, or assessment expressed in reply.",
            "selectedContextSegments records semantic project-context admission; supportSourceReferences records support provenance.",''',
"selection prompt instructions",
)

replace_once(
'''            ...projectContext,
            ...projectContextEvidence,
            ...projectContextWarning,''',
'''            ...projectContext,
            ...projectContextEvidence,
            ...projectContextSegmentCandidates,
            ...projectContextWarning,''',
"candidate prompt insertion",
)

replace_once(
'''    const suppliedConversationSourceIds =
      new Set(''',
'''    const suppliedSegmentCandidates =
      context.projectContextSegmentCandidates || [];

    const suppliedSegmentByIdentity = new Map(
      suppliedSegmentCandidates.map((segment) => [
        `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
        segment,
      ]),
    );

    const deduplicatedSelectedContextSegments =
      result.selectedContextSegments.filter(
        (segment, index, segments) => {
          const identity =
            `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`;

          return segments.findIndex(
            (candidate) =>
              `${candidate.relativePath}:${candidate.sourceStartLine}:${candidate.sourceEndLine}` ===
              identity,
          ) === index;
        },
      );

    for (const segment of deduplicatedSelectedContextSegments) {
      const identity =
        `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`;

      if (!suppliedSegmentByIdentity.has(identity)) {
        throw new Error(
          "Ollama returned a selected context segment that was not supplied in this invocation.",
        );
      }
    }

    const selectedSegmentIdentities = new Set(
      deduplicatedSelectedContextSegments.map(
        (segment) =>
          `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
      ),
    );

    const suppliedConversationSourceIds =
      new Set(''',
"selected membership validation",
)

replace_once(
'''    const supportDrivenEvidenceSources =
      deduplicatedSupportSourceReferences''',
'''    for (const reference of deduplicatedSupportSourceReferences) {
      if (reference.type !== "project_context_excerpt") {
        continue;
      }

      const childrenForParent = suppliedSegmentCandidates.filter(
        (segment) =>
          segment.parentRelativePath === reference.relativePath &&
          segment.parentLineNumber === reference.lineNumber,
      );

      if (childrenForParent.length === 0) {
        continue;
      }

      const hasSelectedChild = childrenForParent.some(
        (segment) =>
          selectedSegmentIdentities.has(
            `${segment.relativePath}:${segment.sourceStartLine}:${segment.sourceEndLine}`,
          ),
      );

      if (!hasSelectedChild) {
        throw new Error(
          "Ollama returned project-context support without selecting a supplied child segment for that parent.",
        );
      }
    }

    const supportDrivenEvidenceSources =
      deduplicatedSupportSourceReferences''',
"support/selection consistency",
)

replace_once(
'''    return {
      ...result,
      supportSourceReferences:
        deduplicatedSupportSourceReferences,
      evidence: validatedEvidence,
      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
    };''',
'''    return {
      reply: result.reply,
      explanationStatus: result.explanationStatus,
      supportSourceReferences:
        deduplicatedSupportSourceReferences,
      evidence: validatedEvidence,
      evidenceSufficient:
        deduplicatedSupportSourceReferences.length > 0,
      durableInterpretation: result.durableInterpretation,
    };''',
"ephemeral selection boundary",
)

path.write_text(text)
print("Implemented Adaptive Detail selected-context contract.")
PY

echo
echo "=== VERIFY CONTRACT ==="
grep -n \
  'selectedContextSegments\|Project-context segment candidates' \
  scripts/utils/ollamaChat.ts

echo
echo "=== TYPECHECK — KNOWN BASELINE ERROR ALLOWED ONLY ==="
set +e
typecheck_output="$(npx tsc --noEmit 2>&1)"
typecheck_rc=$?
set -e
printf '%s\n' "$typecheck_output"

if [[ "$typecheck_rc" -ne 0 ]]; then
  unexpected_typecheck="$(
    printf '%s\n' "$typecheck_output" |
    grep 'error TS' |
    grep -v 'routes/atlas/why.ts:32:54 - error TS2554' ||
    true
  )"

  if [[ -n "$unexpected_typecheck" ]]; then
    echo "STOP: new TypeScript errors detected."
    exit 2
  fi

  echo "KNOWN_BASELINE_TYPE_ERROR_ONLY"
fi

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_PROMPT_SELECTED_CONTEXT_CONTRACT_IMPLEMENTED"
echo "SELECTED_CONTEXT_SEGMENTS_NOT_PERSISTED"
echo "ONE_MODEL_INVOCATION_PRESERVED"
echo "EVIDENCE_COMPOSITION_SEMANTICS_UNCHANGED"
echo "NEXT_UNIT=VALIDATE_ADAPTIVE_DETAIL_SELECTED_CONTEXT_SEGMENTS_CONTRACT"

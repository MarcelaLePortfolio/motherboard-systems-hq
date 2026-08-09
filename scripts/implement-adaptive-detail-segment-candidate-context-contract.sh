#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT ADAPTIVE DETAIL — SEGMENT CANDIDATE CONTEXT CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "749abcaa" ]]; then
  echo "STOP: HEAD no longer matches inspected baseline 749abcaa."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-segment-candidate-context-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

retrieval = Path("server/matilda-project-context-retrieval.ts")
text = retrieval.read_text()

old = '''interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  matchedLineNumber: number;
  startLineNumber: number;
  endLineNumber: number;
  content: string;
}'''

new = '''export interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}'''

if old not in text:
    raise SystemExit(
        "STOP: inspected internal segment candidate contract changed."
    )

text = text.replace(old, new, 1)

text = text.replace(
'''      matchedLineNumber: input.matchedLineNumber,
      startLineNumber:
        input.sourceStartLine + segmentStartIndex,
      endLineNumber:
        input.sourceStartLine + exclusiveEndIndex - 1,
      content: segmentLines.join("\\n"),''',
'''      sourceStartLine:
        input.sourceStartLine + segmentStartIndex,
      sourceEndLine:
        input.sourceStartLine + exclusiveEndIndex - 1,
      text: segmentLines.join("\\n"),''',
1,
)

old = '''    const excerpts: MatildaProjectContextExcerpt[] = [];

    for (const candidate of selectedCandidates.slice(0, MAX_MATCHES)) {'''

new = '''    const excerpts: MatildaProjectContextExcerpt[] = [];
    const projectContextSegmentCandidates:
      MatildaProjectContextSegmentCandidate[] = [];

    for (const candidate of selectedCandidates.slice(0, MAX_MATCHES)) {'''

if old not in text:
    raise SystemExit(
        "STOP: inspected excerpt assembly seam changed."
    )

text = text.replace(old, new, 1)

old = '''      segmentBoundedProjectContextSource({
        relativePath: candidate.relativePath,
        matchedLineNumber: candidate.lineNumber,
        sourceStartLine:
          boundedExcerpt.metadata.sourceStartLine,
        boundedSourceLines:
          boundedExcerpt.boundedSourceLines,
      });

      excerpts.push({'''

new = '''      const admittedExcerpt =
        boundedExcerpt.excerpt;

      const sourceSegments =
        segmentBoundedProjectContextSource({
          relativePath: candidate.relativePath,
          matchedLineNumber: candidate.lineNumber,
          sourceStartLine:
            boundedExcerpt.metadata.sourceStartLine,
          boundedSourceLines:
            boundedExcerpt.boundedSourceLines,
        });

      let admittedCharacters = 0;

      for (const segment of sourceSegments) {
        const segmentText = segment.text.trim();

        if (!segmentText) {
          continue;
        }

        const segmentOffset =
          admittedExcerpt.indexOf(
            segmentText,
            admittedCharacters,
          );

        if (segmentOffset < 0) {
          continue;
        }

        const segmentEndOffset =
          segmentOffset + segmentText.length;

        if (
          segmentEndOffset >
          admittedExcerpt.length
        ) {
          continue;
        }

        projectContextSegmentCandidates.push(
          segment,
        );

        admittedCharacters =
          segmentEndOffset;
      }

      excerpts.push({'''

if old not in text:
    raise SystemExit(
        "STOP: inspected inert segmentation call changed."
    )

text = text.replace(old, new, 1)

old = '''      queryTerms,
      excerpts,
      warning: null,
    };'''

new = '''      queryTerms,
      excerpts,
      projectContextSegmentCandidates,
      warning: null,
    };'''

if old not in text:
    raise SystemExit(
        "STOP: successful retrieval return seam changed."
    )

text = text.replace(old, new, 1)

# Add empty candidate collections to all early/failure return paths.
text = text.replace(
'''      queryTerms,
      excerpts: [],
      warning:''',
'''      queryTerms,
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning:''',
)

text = text.replace(
'''      queryTerms,
      excerpts: [],
      warning: null,''',
'''      queryTerms,
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning: null,''',
)

retrieval.write_text(text)

print("Updated retrieval candidate contract and additive retrieval result.")
PY

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-project-context-retrieval.ts")
text = path.read_text()

marker = '''export interface MatildaProjectContextExcerpt'''

result_match = '''export interface MatildaProjectContextRetrievalResult {'''

if result_match not in text:
    raise SystemExit(
        "STOP: retrieval result interface not found."
    )

start = text.index(result_match)
end = text.index("}\n", start) + 2
block = text[start:end]

if "projectContextSegmentCandidates" not in block:
    block = block.replace(
        "  excerpts: MatildaProjectContextExcerpt[];\n",
        "  excerpts: MatildaProjectContextExcerpt[];\n"
        "  projectContextSegmentCandidates:\n"
        "    MatildaProjectContextSegmentCandidate[];\n",
        1,
    )

    text = text[:start] + block + text[end:]

path.write_text(text)

print("Extended retrieval result contract.")
PY

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-conversation-context-runtime.ts")
text = path.read_text()

old = '''  projectContextExcerpts:
    MatildaProjectContextRetrievalResult["excerpts"];
  projectContextWarning: string | null;'''

new = '''  projectContextExcerpts:
    MatildaProjectContextRetrievalResult["excerpts"];
  projectContextSegmentCandidates:
    MatildaProjectContextRetrievalResult["projectContextSegmentCandidates"];
  projectContextWarning: string | null;'''

if old not in text:
    raise SystemExit(
        "STOP: conversation-context interface seam changed."
    )

text = text.replace(old, new, 1)

old = '''    projectContextExcerpts:
      input.projectContextRetrieval.excerpts,
    projectContextWarning:
      input.projectContextRetrieval.warning,'''

new = '''    projectContextExcerpts:
      input.projectContextRetrieval.excerpts,
    projectContextSegmentCandidates:
      input.projectContextRetrieval
        .projectContextSegmentCandidates,
    projectContextWarning:
      input.projectContextRetrieval.warning,'''

if old not in text:
    raise SystemExit(
        "STOP: conversation-context return seam changed."
    )

path.write_text(text)

print("Added conversation-context candidate pass-through.")
PY

python3 <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''export interface OllamaChatProjectContextExcerpt {
  relativePath: string;
  lineNumber: number;
  excerpt: string;
  provenance: "git_tracked_project_file";
  authorityStatus: "candidate_evidence_not_authority";
}'''

new = '''export interface OllamaChatProjectContextExcerpt {
  relativePath: string;
  lineNumber: number;
  excerpt: string;
  provenance: "git_tracked_project_file";
  authorityStatus: "candidate_evidence_not_authority";
}

export interface OllamaChatProjectContextSegmentCandidate {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}'''

if old not in text:
    raise SystemExit(
        "STOP: Ollama project-context excerpt contract changed."
    )

text = text.replace(old, new, 1)

old = '''  projectContextExcerpts?: OllamaChatProjectContextExcerpt[];
  projectContextWarning?: string | null;'''

new = '''  projectContextExcerpts?: OllamaChatProjectContextExcerpt[];
  projectContextSegmentCandidates?:
    OllamaChatProjectContextSegmentCandidate[];
  projectContextWarning?: string | null;'''

if old not in text:
    raise SystemExit(
        "STOP: OllamaChatContext seam changed."
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("Added inert optional OllamaChatContext candidate field.")
PY

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

old = '''        projectContextExcerpts:
          conversationContext.projectContextExcerpts,
        projectContextWarning:
          conversationContext.projectContextWarning,'''

new = '''        projectContextExcerpts:
          conversationContext.projectContextExcerpts,
        projectContextSegmentCandidates:
          conversationContext
            .projectContextSegmentCandidates,
        projectContextWarning:
          conversationContext.projectContextWarning,'''

if old not in text:
    raise SystemExit(
        "STOP: workflow Ollama context seam changed."
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("Added workflow candidate pass-through.")
PY

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-conversation-context-runtime.test.ts")
text = path.read_text()

text = text.replace(
'''    excerpts: [],
    warning: null,''',
'''    excerpts: [],
    projectContextSegmentCandidates: [],
    warning: null,''',
1,
)

path.write_text(text)

print("Updated conversation-context fixture for additive retrieval field.")
PY

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== SEGMENTATION + RANGE TESTS ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segmentation.test.ts \
  server/matilda-project-context-retrieval.range-metadata.test.ts \
  server/matilda-project-context-retrieval.test.ts

echo
echo "=== CONVERSATION CONTEXT TESTS ==="
npx tsx --test \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY CANDIDATES ARE NOT PROMPT-SERIALIZED ==="
candidate_prompt_refs="$(
  grep -n \
    'projectContextSegmentCandidates' \
    scripts/utils/ollamaChat.ts || true
)"
printf '%s\n' "$candidate_prompt_refs"

candidate_ref_count="$(
  printf '%s\n' "$candidate_prompt_refs" |
  grep -c 'projectContextSegmentCandidates' || true
)"

if [[ "$candidate_ref_count" -ne 1 ]]; then
  echo "STOP: candidate field appears outside the inert OllamaChatContext contract."
  exit 2
fi

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEGMENT_CANDIDATE_CONTEXT_CONTRACT_IMPLEMENTED"
echo "PROMPT_SERIALIZATION_NOT_STARTED"
echo "SELECTED_CONTEXT_SEGMENTS_NOT_STARTED"

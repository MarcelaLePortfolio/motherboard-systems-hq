#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT ADAPTIVE DETAIL — SEGMENT PARENT IDENTITY ==="

if [[ "$(git rev-parse --short HEAD)" != "45567c52" ]]; then
  echo "STOP: HEAD no longer matches support-reconciliation investigation checkpoint 45567c52."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-segment-parent-identity\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

targets = [
    Path("server/matilda-project-context-retrieval.ts"),
    Path("scripts/utils/ollamaChat.ts"),
]

for path in targets:
    text = path.read_text()

    old = """export interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}"""

    if path.name == "ollamaChat.ts":
        old = """export interface OllamaChatProjectContextSegmentCandidate {
  relativePath: string;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}"""

    if old not in text:
        raise SystemExit(
            f"STOP: expected segment candidate contract not found in {path}."
        )

    interface_name = (
        "OllamaChatProjectContextSegmentCandidate"
        if path.name == "ollamaChat.ts"
        else "MatildaProjectContextSegmentCandidate"
    )

    new = f"""export interface {interface_name} {{
  relativePath: string;
  parentRelativePath: string;
  parentLineNumber: number;
  sourceStartLine: number;
  sourceEndLine: number;
  text: string;
}}"""

    path.write_text(text.replace(old, new, 1))

retrieval = Path("server/matilda-project-context-retrieval.ts")
text = retrieval.read_text()

old_input = """function segmentBoundedProjectContextSource(input: {
  relativePath: string;
  matchedLineNumber: number;
  sourceStartLine: number;
  boundedSourceLines: readonly string[];
}): MatildaProjectContextSegmentCandidate[] {"""

new_input = """function segmentBoundedProjectContextSource(input: {
  relativePath: string;
  matchedLineNumber: number;
  sourceStartLine: number;
  boundedSourceLines: readonly string[];
}): MatildaProjectContextSegmentCandidate[] {"""

if old_input not in text:
    raise SystemExit(
        "STOP: expected segmentation input contract not found."
    )

old_push = """    segments.push({
      relativePath: input.relativePath,
      sourceStartLine:
        input.sourceStartLine + segmentStartIndex,
      sourceEndLine:
        input.sourceStartLine + exclusiveEndIndex - 1,
      text: segmentLines.join("\\n"),
    });"""

new_push = """    segments.push({
      relativePath: input.relativePath,
      parentRelativePath: input.relativePath,
      parentLineNumber: input.matchedLineNumber,
      sourceStartLine:
        input.sourceStartLine + segmentStartIndex,
      sourceEndLine:
        input.sourceStartLine + exclusiveEndIndex - 1,
      text: segmentLines.join("\\n"),
    });"""

if old_push not in text:
    raise SystemExit(
        "STOP: expected segment construction path not found."
    )

retrieval.write_text(text.replace(old_push, new_push, 1))

print("Added deterministic parent excerpt identity to segment candidates.")
PY

cat > server/matilda-project-context-retrieval.segment-parent-identity.test.ts <<'TEST_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL(
    "./matilda-project-context-retrieval.ts",
    import.meta.url,
  ),
  "utf8",
);

test("segment candidate contract preserves deterministic parent excerpt identity", () => {
  const contract =
    source.match(
      /export interface MatildaProjectContextSegmentCandidate \{[\s\S]*?\n\}/,
    )?.[0] ?? "";

  assert.match(
    contract,
    /parentRelativePath:\s*string/,
  );

  assert.match(
    contract,
    /parentLineNumber:\s*number/,
  );

  assert.match(
    contract,
    /sourceStartLine:\s*number/,
  );

  assert.match(
    contract,
    /sourceEndLine:\s*number/,
  );
});

test("segment construction derives parent identity from the admitted parent excerpt candidate", () => {
  const construction =
    source.match(
      /segments\.push\(\{[\s\S]*?text:\s*segmentLines\.join\("\\n"\),[\s\S]*?\}\);/,
    )?.[0] ?? "";

  assert.match(
    construction,
    /parentRelativePath:\s*input\.relativePath/,
  );

  assert.match(
    construction,
    /parentLineNumber:\s*input\.matchedLineNumber/,
  );
});

test("parent identity does not replace exact child source-range identity", () => {
  const construction =
    source.match(
      /segments\.push\(\{[\s\S]*?text:\s*segmentLines\.join\("\\n"\),[\s\S]*?\}\);/,
    )?.[0] ?? "";

  assert.match(
    construction,
    /sourceStartLine:[\s\S]*?input\.sourceStartLine \+ segmentStartIndex/,
  );

  assert.match(
    construction,
    /sourceEndLine:[\s\S]*?input\.sourceStartLine \+ exclusiveEndIndex - 1/,
  );
});
TEST_EOF

echo
echo "=== PARENT IDENTITY CONTRACT TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segment-parent-identity.test.ts

echo
echo "=== SEGMENTATION REGRESSION TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== RANGE + RETRIEVAL REGRESSION TESTS ==="
npx tsx --test \
  server/matilda-project-context-retrieval.range-metadata.test.ts \
  server/matilda-project-context-retrieval.test.ts \
  server/matilda-conversation-context-runtime.test.ts

echo
echo "=== EVIDENCE REGRESSION TESTS ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY SEGMENT CANDIDATES REMAIN UNSERIALIZED ==="
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
  echo "STOP: segment candidates appear outside the inert OllamaChatContext contract."
  exit 2
fi

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEGMENT_PARENT_IDENTITY_IMPLEMENTED"
echo "PROMPT_SERIALIZATION_NOT_STARTED"
echo "SELECTED_CONTEXT_SEGMENTS_NOT_STARTED"
echo "SUPPORT_REFERENCE_SEMANTICS_UNCHANGED"
echo "EVIDENCE_COMPOSITION_UNCHANGED"

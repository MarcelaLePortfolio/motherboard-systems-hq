#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT ADAPTIVE DETAIL — DETERMINISTIC SEGMENTATION PRIMITIVE ==="

if [[ "$(git rev-parse --short HEAD)" != "7b4d714f" ]]; then
  echo "STOP: HEAD no longer matches segmentation-contract checkpoint 7b4d714f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-deterministic-segmentation-primitive\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-project-context-retrieval.ts")
text = path.read_text()

old_interface = '''interface MatildaBoundedExcerptReadResult {
  excerpt: string;
  metadata: {
    sourceStartLine: number;
    sourceEndLine: number;
    excerptTruncated: boolean;
  };
}
'''

new_interface = '''interface MatildaProjectContextSegmentCandidate {
  relativePath: string;
  matchedLineNumber: number;
  startLineNumber: number;
  endLineNumber: number;
  content: string;
}

interface MatildaBoundedExcerptReadResult {
  excerpt: string;
  metadata: {
    sourceStartLine: number;
    sourceEndLine: number;
    excerptTruncated: boolean;
  };
  boundedSourceLines: string[];
}
'''

if old_interface not in text:
    raise SystemExit(
        "STOP: bounded excerpt result contract no longer matches inspected seam."
    )

text = text.replace(old_interface, new_interface, 1)

old_reader = '''    const boundedSource = lines
      .slice(start, end)
      .join("\\n")
      .trim();

    return {
      excerpt: boundedSource.slice(0, MAX_EXCERPT_CHARACTERS),
      metadata: {
        sourceStartLine: start + 1,
        sourceEndLine: end,
        excerptTruncated:
          boundedSource.length > MAX_EXCERPT_CHARACTERS,
      },
    };
'''

new_reader = '''    const boundedSourceLines = lines.slice(start, end);
    const boundedSource = boundedSourceLines
      .join("\\n")
      .trim();

    return {
      excerpt: boundedSource.slice(0, MAX_EXCERPT_CHARACTERS),
      metadata: {
        sourceStartLine: start + 1,
        sourceEndLine: end,
        excerptTruncated:
          boundedSource.length > MAX_EXCERPT_CHARACTERS,
      },
      boundedSourceLines,
    };
'''

if old_reader not in text:
    raise SystemExit(
        "STOP: bounded excerpt materialization no longer matches inspected seam."
    )

text = text.replace(old_reader, new_reader, 1)

marker = '''export function retrieveMatildaProjectContext(input: {
'''

segmenter = '''function segmentBoundedProjectContextSource(input: {
  relativePath: string;
  matchedLineNumber: number;
  sourceStartLine: number;
  boundedSourceLines: readonly string[];
}): MatildaProjectContextSegmentCandidate[] {
  const segments: MatildaProjectContextSegmentCandidate[] = [];
  let segmentStartIndex: number | null = null;

  const flushSegment = (exclusiveEndIndex: number): void => {
    if (segmentStartIndex === null) {
      return;
    }

    const segmentLines = input.boundedSourceLines.slice(
      segmentStartIndex,
      exclusiveEndIndex
    );

    segments.push({
      relativePath: input.relativePath,
      matchedLineNumber: input.matchedLineNumber,
      startLineNumber:
        input.sourceStartLine + segmentStartIndex,
      endLineNumber:
        input.sourceStartLine + exclusiveEndIndex - 1,
      content: segmentLines.join("\\n"),
    });

    segmentStartIndex = null;
  };

  for (
    let index = 0;
    index < input.boundedSourceLines.length;
    index += 1
  ) {
    if (input.boundedSourceLines[index].trim() === "") {
      flushSegment(index);
      continue;
    }

    if (segmentStartIndex === null) {
      segmentStartIndex = index;
    }
  }

  flushSegment(input.boundedSourceLines.length);

  return segments;
}

'''

if marker not in text:
    raise SystemExit(
        "STOP: retrieval export seam was not found."
    )

text = text.replace(marker, segmenter + marker, 1)

old_call = '''      if (!boundedExcerpt) {
        continue;
      }

      excerpts.push({
'''

new_call = '''      if (!boundedExcerpt) {
        continue;
      }

      segmentBoundedProjectContextSource({
        relativePath: candidate.relativePath,
        matchedLineNumber: candidate.lineNumber,
        sourceStartLine:
          boundedExcerpt.metadata.sourceStartLine,
        boundedSourceLines:
          boundedExcerpt.boundedSourceLines,
      });

      excerpts.push({
'''

if old_call not in text:
    raise SystemExit(
        "STOP: excerpt assembly seam no longer matches inspected state."
    )

text = text.replace(old_call, new_call, 1)

path.write_text(text)
print("Implemented inert deterministic blank-line segmentation primitive.")
PY

cat > server/matilda-project-context-retrieval.segmentation.test.ts <<'TEST_EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync(
  "server/matilda-project-context-retrieval.ts",
  "utf8",
);

test(
  "bounded excerpt retains pre-trim pre-truncation source lines internally",
  () => {
    assert.match(
      source,
      /boundedSourceLines:\s*string\[\]/,
    );

    assert.match(
      source,
      /const boundedSourceLines = lines\.slice\(start, end\)/,
    );

    assert.match(
      source,
      /boundedSourceLines,\s*\n\s*};/,
    );
  },
);

test(
  "deterministic segment candidate preserves exact source-range identity",
  () => {
    assert.match(
      source,
      /interface MatildaProjectContextSegmentCandidate/,
    );

    assert.match(
      source,
      /relativePath:\s*string/,
    );

    assert.match(
      source,
      /matchedLineNumber:\s*number/,
    );

    assert.match(
      source,
      /startLineNumber:\s*number/,
    );

    assert.match(
      source,
      /endLineNumber:\s*number/,
    );

    assert.match(
      source,
      /content:\s*string/,
    );
  },
);

test(
  "segmentation uses blank lines structurally without semantic filtering",
  () => {
    assert.match(
      source,
      /input\.boundedSourceLines\[index\]\.trim\(\) === ""/,
    );

    assert.match(
      source,
      /segmentLines\.join\("\\\\n"\)/,
    );

    assert.doesNotMatch(
      source,
      /segment.*relevan|segment.*material|semantic.*segment/i,
    );
  },
);

test(
  "segment ordering and exact line ranges derive from source order",
  () => {
    assert.match(
      source,
      /let index = 0;[\s\S]*index < input\.boundedSourceLines\.length;[\s\S]*index \+= 1/,
    );

    assert.match(
      source,
      /startLineNumber:\s*[\s\S]*input\.sourceStartLine \+ segmentStartIndex/,
    );

    assert.match(
      source,
      /endLineNumber:\s*[\s\S]*input\.sourceStartLine \+ exclusiveEndIndex - 1/,
    );
  },
);

test(
  "empty blank-line units are not emitted as segments",
  () => {
    assert.match(
      source,
      /if \(segmentStartIndex === null\) \{\s*return;\s*\}/,
    );
  },
);

test(
  "segmentation remains inert and public excerpt assembly is unchanged",
  () => {
    const assembly =
      source.match(
        /excerpts\.push\(\{[\s\S]*?authorityStatus:\s*"candidate_evidence_not_authority",[\s\S]*?\}\);/,
      )?.[0] ?? "";

    assert.notEqual(
      assembly,
      "",
      "public excerpt assembly was not found",
    );

    assert.match(
      assembly,
      /relativePath:\s*candidate\.relativePath/,
    );

    assert.match(
      assembly,
      /lineNumber:\s*candidate\.lineNumber/,
    );

    assert.match(
      assembly,
      /excerpt:\s*boundedExcerpt\.excerpt/,
    );

    assert.doesNotMatch(
      assembly,
      /segment|startLineNumber|endLineNumber|boundedSourceLines/,
    );
  },
);

test(
  "segmentation does not alter the public project-context excerpt contract",
  () => {
    const publicContract =
      source.match(
        /export interface MatildaProjectContextExcerpt\s*\{[\s\S]*?\n\}/,
      )?.[0] ?? "";

    assert.notEqual(
      publicContract,
      "",
      "MatildaProjectContextExcerpt contract was not found",
    );

    assert.doesNotMatch(
      publicContract,
      /segment|startLineNumber|endLineNumber|boundedSourceLines/,
    );
  },
);
TEST_EOF

echo
echo "=== SEGMENTATION CONTRACT TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.segmentation.test.ts

echo
echo "=== RANGE METADATA REGRESSION TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.range-metadata.test.ts

echo
echo "=== RETRIEVAL REGRESSION TEST ==="
npx tsx --test \
  server/matilda-project-context-retrieval.test.ts

echo
echo "=== CONVERSATION CONTEXT REGRESSION TEST ==="
npx tsx --test \
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
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_DETERMINISTIC_SEGMENTATION_PRIMITIVE_IMPLEMENTED"
echo "SEMANTIC_ADMISSION_NOT_STARTED"

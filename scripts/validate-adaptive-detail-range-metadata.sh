#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — RANGE METADATA ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

if [[ "$(git rev-parse --short HEAD)" != "9d7f654f" ]]; then
  echo "STOP: HEAD no longer matches range-metadata implementation checkpoint 9d7f654f."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-range-metadata\.sh$|^\?\? server/matilda-project-context-retrieval\.range-metadata\.test\.ts$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat > server/matilda-project-context-retrieval.range-metadata.test.ts <<'TEST_EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

const source = fs.readFileSync(
  "server/matilda-project-context-retrieval.ts",
  "utf8",
);

test(
  "bounded excerpt reader records exact source-range metadata internally",
  () => {
    assert.match(
      source,
      /interface MatildaBoundedExcerptReadResult/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*number/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*number/,
    );

    assert.match(
      source,
      /excerptTruncated:\s*boolean/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*start \+ 1/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*end/,
    );
  },
);

test(
  "truncation metadata derives from the existing excerpt character cap",
  () => {
    assert.match(
      source,
      /excerpt:\s*boundedSource\.slice\(0,\s*MAX_EXCERPT_CHARACTERS\)/,
    );

    assert.match(
      source,
      /boundedSource\.length\s*>\s*MAX_EXCERPT_CHARACTERS/,
    );
  },
);

test(
  "range metadata does not alter the public project-context excerpt contract",
  () => {
    const publicContract =
      source.match(
        /export interface MatildaProjectContextExcerpt\s*\{[\s\S]*?\n\}/,
      )?.[0] ?? "";

    assert.notEqual(
      publicContract,
      "",
      "MatildaProjectContextExcerpt contract was not found.",
    );

    assert.doesNotMatch(
      publicContract,
      /sourceStartLine|sourceEndLine|excerptTruncated|metadata/,
    );
  },
);

test(
  "retrieval continues to publish the existing excerpt identity and text",
  () => {
    assert.match(
      source,
      /relativePath:\s*candidate\.relativePath/,
    );

    assert.match(
      source,
      /lineNumber:\s*candidate\.lineNumber/,
    );

    assert.match(
      source,
      /excerpt:\s*boundedExcerpt\.excerpt/,
    );

    assert.match(
      source,
      /provenance:\s*"git_tracked_project_file"/,
    );

    assert.match(
      source,
      /authorityStatus:\s*"candidate_evidence_not_authority"/,
    );
  },
);
TEST_EOF

echo
echo "=== RANGE METADATA CONTRACT TEST ==="
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
echo "ADAPTIVE_DETAIL_RANGE_METADATA_VALIDATED"

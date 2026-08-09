#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

EXPECTED_HEAD="159a8b93"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches stale-validator classification checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat > scripts/validate-source-excerpt-first-live.ts <<'TS_EOF'
import { ollamaChat } from "./utils/ollamaChat";

async function main() {
  const relativePath =
    "server/matilda-chat-workflow.ts";
  const parentLineNumber = 155;
  const suppliedExcerpt =
    "const ollamaResult = await ollamaChat(message, {";

  const suppliedSegment = {
    relativePath,
    parentRelativePath: relativePath,
    parentLineNumber,
    sourceStartLine: parentLineNumber,
    sourceEndLine: parentLineNumber,
    text: suppliedExcerpt,
  };

  const result = await ollamaChat(
    "What repository evidence shows that this workflow invokes ollamaChat?",
    {
      history: [
        {
          sourceTurnId:
            "turn-source-excerpt-live-validation",
          userMessage:
            "We need repository evidence for the workflow invocation seam.",
          assistantReply:
            "The repository excerpt should establish that directly.",
        },
      ],
      projectContextExcerpts: [
        {
          relativePath,
          lineNumber: parentLineNumber,
          excerpt: suppliedExcerpt,
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
      projectContextSegmentCandidates: [
        suppliedSegment,
      ],
    },
  );

  console.log(
    "=== SOURCE-EXCERPT-FIRST LIVE VALIDATION ===",
  );
  console.log();

  console.log("REPLY");
  console.log(result.reply);
  console.log();

  console.log("EVIDENCE");
  console.log(
    JSON.stringify(result.evidence, null, 2),
  );
  console.log();

  console.log("OVERALL SUPPORT REFERENCES");
  console.log(
    JSON.stringify(
      result.supportSourceReferences,
      null,
      2,
    ),
  );
  console.log();

  console.log("EVIDENCE SUFFICIENT");
  console.log(result.evidenceSufficient);
  console.log();

  console.log("=== DETERMINATION ===");

  const evidence = result.evidence;

  if (!evidence) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_INCONCLUSIVE: model returned null evidence.",
    );
    process.exitCode = 2;
    return;
  }

  if (evidence.sources.length !== 1) {
    console.log(
      `SOURCE_EXCERPT_FIRST_LIVE_FAIL: expected exactly one validated evidence source, received ${evidence.sources.length}.`,
    );
    process.exitCode = 2;
    return;
  }

  const source = evidence.sources[0];

  if (
    source.reference.type !==
      "project_context_excerpt" ||
    source.reference.relativePath !==
      relativePath ||
    source.reference.lineNumber !==
      parentLineNumber
  ) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_FAIL: evidence source identity does not match the supplied repository source.",
    );
    process.exitCode = 2;
    return;
  }

  if (source.excerpt !== suppliedExcerpt) {
    console.log(
      "SOURCE_EXCERPT_FIRST_LIVE_FAIL: evidence excerpt is not an exact reproduction of supplied source material.",
    );
    process.exitCode = 2;
    return;
  }

  console.log(
    "SOURCE_EXCERPT_FIRST_LIVE_SUPPORTED",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
TS_EOF

cat > scripts/validate-source-excerpt-first-live-contract.test.ts <<'TS_EOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  "scripts/validate-source-excerpt-first-live.ts",
  "utf8",
);

test(
  "Source-Excerpt live validator supplies current child-candidate contract",
  () => {
    assert.match(
      source,
      /projectContextSegmentCandidates:\s*\[/,
    );

    assert.match(
      source,
      /parentRelativePath:\s*relativePath/,
    );

    assert.match(
      source,
      /parentLineNumber/,
    );

    assert.match(
      source,
      /sourceStartLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /sourceEndLine:\s*parentLineNumber/,
    );

    assert.match(
      source,
      /text:\s*suppliedExcerpt/,
    );
  },
);

test(
  "Source-Excerpt live validator preserves parent Source identity",
  () => {
    assert.match(
      source,
      /"server\/matilda-chat-workflow\.ts"/,
    );

    assert.match(
      source,
      /const parentLineNumber = 155/,
    );
  },
);
TS_EOF

echo "=== VALIDATOR CONTRACT TEST ==="
npx tsx --test \
  scripts/validate-source-excerpt-first-live-contract.test.ts

echo
echo "=== EVIDENCE COMPOSITION STRUCTURAL CHECK ==="
./scripts/validate-evidence-composition-corridor-closure.sh
closure_rc=$?

if [[ "$closure_rc" -ne 0 ]]; then
  echo "STOP: reconciled Evidence Composition closure check failed."
  exit "$closure_rc"
fi

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during validation-only reconciliation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/validate-source-excerpt-first-live\.ts$|^scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside validation-only reconciliation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "VALIDATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "SOURCE_EXCERPT_LIVE_VALIDATOR_RECONCILED"
echo "EVIDENCE_COMPOSITION_CLOSURE_VALIDATED"
echo "PRODUCTION_RUNTIME_UNCHANGED"
echo "PHASE_2_START=STILL_BLOCKED_PENDING_PHASE_1_RECLASSIFICATION"
echo "NEXT_ACTION=RECLASSIFY_PHASE_1_RESPONSE_COMPOSITION_STATE"

git add \
  scripts/validate-source-excerpt-first-live.ts \
  scripts/validate-source-excerpt-first-live-contract.test.ts \
  scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract.sh

git commit -m "Reconcile Source-Excerpt live validator with selected context contract"
git push

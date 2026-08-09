#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE ADAPTIVE DETAIL — SEEDED REPRODUCIBILITY ==="

if [[ "$(git rev-parse --short HEAD)" != "52bf902b" ]]; then
  echo "STOP: HEAD no longer matches validation-only seed checkpoint 52bf902b."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-adaptive-detail-seeded-reproducibility\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat > scripts/validate-adaptive-detail-mixed-content-seeded-live.ts <<'TS_EOF'
import { ollamaChat } from "./utils/ollamaChat";

const VALIDATION_SEED = 424242;

async function main() {
  let selectedContextSegments:
    | readonly {
        relativePath: string;
        sourceStartLine: number;
        sourceEndLine: number;
      }[]
    | undefined;

  let parsedSupportSourceReferences:
    | readonly {
        type: string;
        relativePath?: string;
        lineNumber?: number;
        sourceTurnId?: string;
      }[]
    | undefined;

  const result = await ollamaChat(
    "Is the selected-context validation observer used by the normal production workflow? Answer only what matters to that question.",
    {
      projectId: "adaptive-detail-live-validation",
      projectDisplayName: "Adaptive Detail Live Validation",
      projectContextExcerpts: [
        {
          projectId: "adaptive-detail-live-validation",
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          lineNumber: 20,
          excerpt:
            "The selected-context validation observer is optional and absent from the normal production workflow.\n\nA future unrelated migration may redesign the dashboard color palette after the current runtime work is complete.",
          provenance:
            "git_tracked_project_file",
          authorityStatus:
            "candidate_evidence_not_authority",
        },
      ],
      projectContextSegmentCandidates: [
        {
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          parentRelativePath:
            "docs/adaptive-detail-live-validation.md",
          parentLineNumber: 20,
          sourceStartLine: 20,
          sourceEndLine: 20,
          text:
            "The selected-context validation observer is optional and absent from the normal production workflow.",
        },
        {
          relativePath:
            "docs/adaptive-detail-live-validation.md",
          parentRelativePath:
            "docs/adaptive-detail-live-validation.md",
          parentLineNumber: 20,
          sourceStartLine: 22,
          sourceEndLine: 22,
          text:
            "A future unrelated migration may redesign the dashboard color palette after the current runtime work is complete.",
        },
      ],
      validationGenerationSeed:
        VALIDATION_SEED,
      observeValidatedSelectedContextSegments:
        (segments) => {
          selectedContextSegments =
            segments;
        },
      observeParsedSupportSourceReferences:
        (references) => {
          parsedSupportSourceReferences =
            references;
        },
    },
  );

  const relevantSelected =
    selectedContextSegments?.some(
      (segment) =>
        segment.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        segment.sourceStartLine === 20 &&
        segment.sourceEndLine === 20,
    ) ?? false;

  const immaterialSelected =
    selectedContextSegments?.some(
      (segment) =>
        segment.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        segment.sourceStartLine === 22 &&
        segment.sourceEndLine === 22,
    ) ?? false;

  const invalidLine22Support =
    parsedSupportSourceReferences?.some(
      (reference) =>
        reference.type ===
          "project_context_excerpt" &&
        reference.relativePath ===
          "docs/adaptive-detail-live-validation.md" &&
        reference.lineNumber === 22,
    ) ?? false;

  const immaterialDetailInReply =
    /dashboard|color palette|migration/i.test(
      result.reply,
    );

  console.log(
    `VALIDATION_SEED=${VALIDATION_SEED}`,
  );
  console.log(
    `RELEVANT_CHILD_SELECTED=${relevantSelected}`,
  );
  console.log(
    `IMMATERIAL_CHILD_SELECTED=${immaterialSelected}`,
  );
  console.log(
    `INVALID_PARENT_LINE_22=${invalidLine22Support}`,
  );
  console.log(
    `IMMATERIAL_DETAIL_IN_REPLY=${immaterialDetailInReply}`,
  );
  console.log(
    `REPLY=${JSON.stringify(result.reply)}`,
  );
  console.log(
    `SUPPORT=${JSON.stringify(result.supportSourceReferences)}`,
  );

  if (
    relevantSelected &&
    !invalidLine22Support &&
    !immaterialDetailInReply
  ) {
    console.log(
      "SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_SUPPORTED",
    );
    return;
  }

  console.log(
    "SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_NOT_SUPPORTED",
  );
  process.exitCode = 2;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 2;
});
TS_EOF

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent \
  http://localhost:11434/api/tags \
  >/dev/null
echo "OLLAMA_AVAILABLE"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

pass_count=0
invalid_count=0
reply_mismatch_count=0
support_mismatch_count=0
baseline_reply=""
baseline_support=""

for trial in 1 2 3; do
  echo
  echo "=== SEEDED TRIAL $trial ==="

  set +e
  npx tsx \
    scripts/validate-adaptive-detail-mixed-content-seeded-live.ts \
    >"$tmp_dir/trial-$trial.log" 2>&1
  rc=$?
  set -e

  cat "$tmp_dir/trial-$trial.log"

  if grep -q \
    '^SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_SUPPORTED$' \
    "$tmp_dir/trial-$trial.log"
  then
    pass_count=$((pass_count + 1))
  fi

  if grep -q \
    '^INVALID_PARENT_LINE_22=true$' \
    "$tmp_dir/trial-$trial.log"
  then
    invalid_count=$((invalid_count + 1))
  fi

  reply="$(
    grep '^REPLY=' \
      "$tmp_dir/trial-$trial.log" |
      head -1
  )"

  support="$(
    grep '^SUPPORT=' \
      "$tmp_dir/trial-$trial.log" |
      head -1
  )"

  if [[ "$trial" -eq 1 ]]; then
    baseline_reply="$reply"
    baseline_support="$support"
  else
    if [[ "$reply" != "$baseline_reply" ]]; then
      reply_mismatch_count=$((reply_mismatch_count + 1))
    fi

    if [[ "$support" != "$baseline_support" ]]; then
      support_mismatch_count=$((support_mismatch_count + 1))
    fi
  fi

  echo "TRIAL_${trial}_EXIT_CODE=$rc"
done

echo
echo "=== SEEDED REPRODUCIBILITY SUMMARY ==="
echo "SEEDED_BEHAVIOR_SUPPORTED_COUNT=$pass_count"
echo "INVALID_PARENT_LINE_22_COUNT=$invalid_count"
echo "REPLY_MISMATCH_COUNT=$reply_mismatch_count"
echo "SUPPORT_MISMATCH_COUNT=$support_mismatch_count"

if [[ \
  "$pass_count" -eq 3 &&
  "$invalid_count" -eq 0 &&
  "$reply_mismatch_count" -eq 0 &&
  "$support_mismatch_count" -eq 0
]]; then
  classification="ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY_SUPPORTED"
elif [[ \
  "$reply_mismatch_count" -gt 0 ||
  "$support_mismatch_count" -gt 0
]]; then
  classification="ADAPTIVE_DETAIL_SEED_DOES_NOT_FULLY_STABILIZE_OUTPUT"
elif [[ "$invalid_count" -gt 0 ]]; then
  classification="ADAPTIVE_DETAIL_INVALID_SUPPORT_PERSISTS_WITH_FIXED_SEED"
else
  classification="ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY_INCONCLUSIVE"
fi

echo "CLASSIFICATION=$classification"

echo
echo "=== VERIFY PRODUCTION WORKFLOW SEED ABSENT ==="
if grep -n \
  'validationGenerationSeed' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow unexpectedly supplies validation seed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_SEED_ABSENT"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_SEEDED_REPRODUCIBILITY_VALIDATED"
echo "PRODUCTION_GENERATION_POLICY_UNCHANGED"
echo "NEXT_UNIT=CLASSIFY_ADAPTIVE_DETAIL_STABILITY_FROM_SEEDED_EVIDENCE"

git add \
  scripts/validate-adaptive-detail-mixed-content-seeded-live.ts \
  scripts/validate-adaptive-detail-seeded-reproducibility.sh

git commit -m "Validate Adaptive Detail seeded reproducibility"
git push

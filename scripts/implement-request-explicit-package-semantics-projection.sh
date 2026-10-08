#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="db054b0e5"

test "$(git branch --show-current)" = "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git status --porcelain)"

cat > server/matilda-request-explicit-package-semantics.ts << 'TYPESCRIPT'
import type {
  MatildaPackageSemanticsArtifact,
} from "../scripts/utils/ollamaChat";

type PackageSemantics = MatildaPackageSemanticsArtifact;

const EXPLICIT_OPERATION =
  /\b(?:remove|hide|rename|move|add|create|delete|disable|enable|replace|restore|show)\b/i;

const REQUEST_PREFIX =
  /^(?:(?:hi|hello|hey)\s+\w+[,!.]?\s*)?(?:(?:let'?s|please|can you|could you|i want to|i would like to|i'd like to)\s+)*/i;

function extractLiteralOutcome(message: string): string | null {
  const normalized = message.trim().replace(/\s+/g, " ");

  if (!normalized || !EXPLICIT_OPERATION.test(normalized)) {
    return null;
  }

  const match = EXPLICIT_OPERATION.exec(normalized);

  if (!match || match.index === undefined) {
    return null;
  }

  const operationClause = normalized.slice(match.index).trim();

  if (!operationClause) {
    return null;
  }

  const cleaned = operationClause
    .replace(REQUEST_PREFIX, "")
    .replace(/[.!?]+$/, "")
    .trim();

  if (!cleaned || !EXPLICIT_OPERATION.test(cleaned)) {
    return null;
  }

  return cleaned;
}

export function projectRequestExplicitPackageSemantics(
  message: string,
  modelSemantics: PackageSemantics | null,
  explicitUserSemantics: Partial<PackageSemantics> | null | undefined,
): PackageSemantics | null {
  if (explicitUserSemantics?.expectedOutcome != null) {
    return modelSemantics;
  }

  const literalOutcome = extractLiteralOutcome(message);

  if (!literalOutcome) {
    return modelSemantics;
  }

  const base: PackageSemantics = modelSemantics ?? {
    expectedOutcome: null,
    successCriteria: null,
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  return {
    ...base,
    expectedOutcome: literalOutcome,
  };
}
TYPESCRIPT

cat > server/matilda-request-explicit-package-semantics.test.ts << 'TYPESCRIPT'
import assert from "node:assert/strict";
import test from "node:test";

import {
  projectRequestExplicitPackageSemantics,
} from "./matilda-request-explicit-package-semantics";

test("projects the literal concrete request without inventing semantics", () => {
  const message =
    "hi matilda, let's start by making changes the frontend. i want to remove the 'packages' tab from the sidebar while preserving all underlying package runtime functionality and authority.";

  const result = projectRequestExplicitPackageSemantics(
    message,
    null,
    null,
  );

  assert.ok(result);
  assert.match(result.expectedOutcome ?? "", /^remove the 'packages' tab/);
  assert.match(
    result.expectedOutcome ?? "",
    /preserving all underlying package runtime functionality and authority/,
  );
  assert.equal(result.proposedWork, null);
  assert.equal(result.constraints, null);
});

test("does not project vague changes", () => {
  assert.equal(
    projectRequestExplicitPackageSemantics(
      "I want to make changes to the frontend.",
      null,
      null,
    ),
    null,
  );
});

test("preserves explicitly user-authored expectedOutcome", () => {
  const semantics = {
    expectedOutcome: "Exactly user-authored outcome",
    successCriteria: null,
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  assert.deepEqual(
    projectRequestExplicitPackageSemantics(
      "Remove the Packages tab.",
      semantics,
      { expectedOutcome: "Exactly user-authored outcome" },
    ),
    semantics,
  );
});

test("retains unrelated model-authored fields", () => {
  const modelSemantics = {
    expectedOutcome: "Wrong direction",
    successCriteria: "Existing success criterion",
    proposedWork: null,
    proposedArtifacts: null,
    inScope: null,
    outOfScope: null,
    constraints: null,
    unresolvedQuestions: null,
  };

  const result = projectRequestExplicitPackageSemantics(
    "Remove the Packages tab.",
    modelSemantics,
    null,
  );

  assert.equal(result?.expectedOutcome, "Remove the Packages tab");
  assert.equal(
    result?.successCriteria,
    "Existing success criterion",
  );
});
TYPESCRIPT

node --input-type=module << 'JAVASCRIPT'
import fs from "node:fs";

const path = "server/matilda-chat-workflow.ts";
let source = fs.readFileSync(path, "utf8");

const importLine =
  'import { projectRequestExplicitPackageSemantics } from "./matilda-request-explicit-package-semantics";\n';

if (!source.includes(importLine)) {
  source = importLine + source;
}

const original = `    enforceMatildaWorkflowPackageSemanticsRequirement(
      requirePackageSemantics,
      ollamaResult.packageSemantics,
    );`;

const replacement = `    const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        ollamaResult.packageSemantics,
        input.userPackageSemantics,
      );

    enforceMatildaWorkflowPackageSemanticsRequirement(
      requirePackageSemantics,
      reconciledPackageSemantics,
    );`;

if (!source.includes(original)) {
  throw new Error("Workflow reconciliation insertion point not found.");
}

source = source.replace(original, replacement);

const start = source.indexOf(replacement);
const remainder = source.slice(start);
const nextBoundary = remainder.indexOf(
  "\n    return ",
);

if (nextBoundary < 0) {
  throw new Error("Workflow return boundary not found.");
}

const section = remainder.slice(0, nextBoundary);
const count = (
  section.match(/ollamaResult\.packageSemantics/g) ?? []
).length;

if (count !== 3) {
  throw new Error(
    `Unexpected downstream Package Semantics references: ${count}`,
  );
}

const reconciledSection = section.replaceAll(
  "ollamaResult.packageSemantics",
  "reconciledPackageSemantics",
);

source =
  source.slice(0, start) +
  reconciledSection +
  remainder.slice(nextBoundary);

fs.writeFileSync(path, source);
JAVASCRIPT

echo "=== VALIDATION ==="
npx tsc --noEmit
node --test --experimental-strip-types \
  server/matilda-request-explicit-package-semantics.test.ts

echo "=== DIFF REVIEW ==="
git diff --check
git diff --stat
git diff -- server/matilda-chat-workflow.ts

echo "=== IMPLEMENTATION COMPLETE — COMMIT NOT YET AUTHORIZED ==="
echo "DOGFOOD_PERFORMED=NO"
echo "PUSH_PERFORMED=NO"
echo "AWAIT_REVIEW_AND_SEPARATE_COMMIT_AUTHORIZATION=YES"

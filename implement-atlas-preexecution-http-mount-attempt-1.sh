#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="f62ec1047"
ROUTE="server/routes/atlas/preexecution.ts"
INDEX="server/index.ts"
TEST="server/routes/atlas/preexecution-http-mount.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

python3 - <<'PY'
from pathlib import Path

route = Path("server/routes/atlas/preexecution.ts")
text = route.read_text()

if 'import express from "express";' not in text:
    text = 'import express from "express";\n\n' + text

append = r'''

export function createAtlasPreExecutionRouter(): express.Router {
  const router = express.Router();

  router.get("/atlas/preexecution", (req, res) => {
    try {
      const projectId = String(req.query.projectId ?? "");
      const conversationId = String(
        req.query.conversationId ?? "",
      );

      const result = readAtlasPreExecutionRoute({
        projectId,
        conversationId,
      });

      return res.json({
        status: "ok",
        route: "atlas_preexecution_read_route",
        projectId: result.projectId,
        observations: result.observations,
        lineageSequences: result.lineageSequences,
        causalExplanation: false,
        executionHistory: false,
        approvalDecision: false,
        authorityDecision: false,
      });
    } catch (error) {
      return res.status(400).json({
        status: "error",
        route: "atlas_preexecution_read_route",
        error:
          error instanceof Error
            ? error.message
            : String(error),
        causalExplanation: false,
        executionHistory: false,
        approvalDecision: false,
        authorityDecision: false,
      });
    }
  });

  return router;
}

export default createAtlasPreExecutionRouter();
'''

if "createAtlasPreExecutionRouter" not in text:
    text = text.rstrip() + append + "\n"

route.write_text(text)

index = Path("server/index.ts")
index_text = index.read_text()

import_line = 'import atlasPreExecutionRouter from "./routes/atlas/preexecution";\n'
if import_line not in index_text:
    marker = 'import { createProductionGovernanceExecutionRouter } from "./execution/production-governance-execution-composition.js";\n'
    if marker not in index_text:
        raise SystemExit("EXPECTED_IMPORT_MARKER_NOT_FOUND")
    index_text = index_text.replace(marker, marker + import_line, 1)

mount_line = "app.use(atlasPreExecutionRouter);\n"
if mount_line not in index_text:
    marker = "app.use(createProductionGovernanceExecutionRouter());\n"
    if marker not in index_text:
        raise SystemExit("EXPECTED_MOUNT_MARKER_NOT_FOUND")
    index_text = index_text.replace(marker, marker + mount_line, 1)

index.write_text(index_text)
PY

cat > "$TEST" <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  createAtlasPreExecutionRouter,
} from "./preexecution";

test(
  "constructs dedicated Atlas pre-execution HTTP router",
  () => {
    const router = createAtlasPreExecutionRouter();

    assert.ok(router);
    assert.equal(typeof router.use, "function");
  },
);

test(
  "pre-execution router is distinct from execution Atlas routes",
  () => {
    const router = createAtlasPreExecutionRouter();

    const stack = (
      router as unknown as {
        stack?: Array<{
          route?: {
            path?: string;
            methods?: Record<string, boolean>;
          };
        }>;
      }
    ).stack ?? [];

    const routes = stack
      .map((layer) => layer.route)
      .filter(Boolean);

    assert.equal(routes.length, 1);
    assert.equal(routes[0]?.path, "/atlas/preexecution");
    assert.equal(routes[0]?.methods?.get, true);

    assert.equal(
      routes.some(
        (route) => route?.path === "/atlas/analyze",
      ),
      false,
    );

    assert.equal(
      routes.some(
        (route) => route?.path === "/atlas/why",
      ),
      false,
    );
  },
);
TS

echo "===== VALIDATION ====="
git diff --check -- "$ROUTE" "$INDEX" "$TEST"
npx tsc --noEmit
npx tsx --test "$TEST"

echo
echo "===== FORBIDDEN SURFACE CHECK ====="
if git diff -- "$ROUTE" "$INDEX" "$TEST" | grep -E \
  'runAtlasIntelligence|reconstructWhy|ExecutionEvent|buildCausalGraph|ollamaChat|INSERT|UPDATE|DELETE|public/index\.html'
then
  echo "FORBIDDEN_SURFACE_DETECTED=YES"
  exit 2
fi
echo "FORBIDDEN_SURFACE_DETECTED=NO"

echo
echo "===== AUTHORIZED DELTA ====="
git diff --name-only -- "$ROUTE" "$INDEX" "$TEST"

echo
echo "===== ATTEMPT 1 CLASSIFICATION ====="
echo "HTTP_METHOD=GET"
echo "HTTP_PATH=/atlas/preexecution"
echo "PROJECT_SCOPE=REQUIRED"
echo "CONVERSATION_SCOPE=REQUIRED"
echo "MISSING_SCOPE=HTTP_400"
echo "EXISTING_ATLAS_ANALYZE_CHANGE=NO"
echo "EXISTING_ATLAS_WHY_CHANGE=NO"
echo "EXECUTION_EVENT_COERCION=NO"
echo "MODEL_CALL=NO"
echo "PERSISTENCE=NO"
echo "DATABASE_CHANGE=NO"
echo "UI_CHANGE=NO"
echo "MATILDA_CHANGE=NO"
echo "REASONER_CHANGE=NO"
echo "AGGREGATOR_CHANGE=NO"

git add "$ROUTE" "$INDEX" "$TEST"

STAGED="$(git diff --cached --name-only | sort)"
EXPECTED="$(printf '%s\n%s\n%s\n' "$ROUTE" "$INDEX" "$TEST" | sort)"
test "$STAGED" = "$EXPECTED"

git diff --cached --check

git commit -m "Mount Atlas pre-execution read endpoint"
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo
echo "ATLAS_PREEXECUTION_HTTP_MOUNT=COMMITTED_AND_PUSHED"
echo "HTTP_MOUNT_UNIT=CLOSED"
echo "NEXT_ACTION=CLASSIFY_OPERATOR_PRESENTATION_BOUNDARY"
echo "DOGFOOD_CLEANUP=FROZEN"

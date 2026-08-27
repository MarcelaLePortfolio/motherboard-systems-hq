import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import { deriveDecisionListTitle } from "./decisionListTitle";

test("short decision title remains unchanged after whitespace normalization", () => {
  assert.equal(
    deriveDecisionListTitle("  Review   Q3   launch plan  "),
    "Review Q3 launch plan",
  );
});

test("long decision title is shortened to a whole-word boundary", () => {
  const value =
    "Create one reviewable verification checklist confirming the Approvals interface displays request-specific package contents";

  const result = deriveDecisionListTitle(value);

  assert.equal(result.endsWith("…"), true);
  assert.equal(result.length <= 65, true);
  assert.equal(result, "Create one reviewable verification checklist confirming the…");
});

test("long unbroken decision title falls back to bounded character shortening", () => {
  const value = "a".repeat(80);

  assert.equal(
    deriveDecisionListTitle(value),
    `${"a".repeat(64)}…`,
  );
});

test("DecisionListItem applies compact title only to the heading", () => {
  const source = fs.readFileSync(
    "client/src/approvals/ApprovalsWorkspace.tsx",
    "utf8",
  );

  assert.match(
    source,
    /deriveDecisionListTitle\(\s*readText\(\s*request\.evidence\.expected_outcome,\s*request\.evidence\.interpreted_objective,/s,
  );

  assert.match(
    source,
    /executive-inbox-item__summary[\s\S]*readText\(request\.evidence\.interpreted_objective\)/,
  );

  assert.match(
    source,
    /<dt>Expected outcome<\/dt>\s*<dd>\{readText\(request\.evidence\.expected_outcome\)\}<\/dd>/s,
  );
});

test("decision heading is visually contained to two lines", () => {
  const source = fs.readFileSync(
    "client/src/approvals/approvals-workspace.css",
    "utf8",
  );

  assert.match(
    source,
    /\.executive-inbox-item__heading strong\s*\{[\s\S]*display:\s*-webkit-box;[\s\S]*overflow:\s*hidden;[\s\S]*-webkit-box-orient:\s*vertical;[\s\S]*-webkit-line-clamp:\s*2;/s,
  );
});

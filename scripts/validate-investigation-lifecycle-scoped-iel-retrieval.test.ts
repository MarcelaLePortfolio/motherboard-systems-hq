import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const source = readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

test("IEL reader accepts optional project and conversation scope", () => {
  assert.match(
    source,
    /export interface ListInterpretationEvidenceLedgerEntriesOptions/,
  );
  assert.match(source, /projectId\?: string \| null/);
  assert.match(source, /conversationId\?: string \| null/);
});

test("project and conversation scope are applied through SQL", () => {
  assert.match(source, /scopeClauses\.push\("project_id = \?"\)/);
  assert.match(source, /scopeClauses\.push\("conversation_id = \?"\)/);
});

test("scope occurs before ordering and limit", () => {
  const reader = source.slice(
    source.indexOf(
      "export function listInterpretationEvidenceLedgerEntries",
    ),
  );

  const whereIndex = reader.indexOf("${whereClause}");
  const orderIndex = reader.indexOf("ORDER BY created_at DESC");
  const limitIndex = reader.indexOf("LIMIT ?");

  assert.ok(whereIndex >= 0);
  assert.ok(orderIndex > whereIndex);
  assert.ok(limitIndex > orderIndex);
});

test("reader remains bounded", () => {
  assert.match(
    source,
    /Math\.max\(1, Math\.min\(Number\(limit\) \|\| 20, 100\)\)/,
  );
});

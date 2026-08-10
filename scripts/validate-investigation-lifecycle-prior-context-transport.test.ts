import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const workflow = readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

const ollama = readFileSync(
  "scripts/utils/ollamaChat.ts",
  "utf8",
);

test("workflow requests scoped lifecycle rows", () => {
  assert.match(
    workflow,
    /listInterpretationEvidenceLedgerEntries\(\s*100,\s*\{\s*projectId,\s*conversationId,/s,
  );
});

test("workflow selects newest non-null reconstructed lifecycle", () => {
  assert.match(
    workflow,
    /entries\.find\(\s*\(entry\) => entry\.investigationLifecycle !== null,/s,
  );
});

test("workflow transports prior lifecycle unchanged", () => {
  assert.match(
    workflow,
    /priorInvestigationLifecycle,\s*explicitEvidenceRequest/,
  );
});

test("Ollama context carries one nullable typed prior lifecycle", () => {
  assert.match(
    ollama,
    /priorInvestigationLifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
  );
});

test("prompt separates prior lifecycle from current determination", () => {
  assert.match(
    ollama,
    /Prior Matilda-authored Investigation Lifecycle state:/,
  );
  assert.match(
    ollama,
    /Do not treat its lifecycleEvent as the required current lifecycleEvent\./,
  );
  assert.match(
    ollama,
    /Determine the current investigationLifecycle from the current user message and supplied context\./,
  );
});

test("one Ollama invocation remains", () => {
  assert.equal(
    (ollama.match(/fetch\(/g) || []).length,
    1,
  );
});

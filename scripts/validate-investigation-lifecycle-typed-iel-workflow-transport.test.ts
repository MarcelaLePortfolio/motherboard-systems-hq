import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const ielSource = fs.readFileSync(
  "db/matilda-interpretation-runtime.ts",
  "utf8",
);

const workflowSource = fs.readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

test(
  "IEL accepts typed Investigation Lifecycle artifact",
  () => {
    assert.match(
      ielSource,
      /investigation_lifecycle\?:\s*MatildaInvestigationLifecycleArtifact \| null;/,
    );

    assert.doesNotMatch(
      ielSource,
      /investigation_lifecycle_json\?: string \| null;/,
    );
  },
);

test(
  "IEL owns lifecycle JSON serialization",
  () => {
    assert.match(
      ielSource,
      /investigation_lifecycle_json:\s*[\s\S]*input\.investigation_lifecycle[\s\S]*JSON\.stringify/,
    );
  },
);

test(
  "null lifecycle remains SQL null",
  () => {
    assert.match(
      ielSource,
      /input\.investigation_lifecycle === null[\s\S]*\? null/,
    );
  },
);

test(
  "workflow directly transports Matilda-authored lifecycle artifact",
  () => {
    assert.match(
      workflowSource,
      /investigation_lifecycle:\s*[\r\n ]*ollamaResult\.investigationLifecycle/,
    );
  },
);

test(
  "workflow does not serialize lifecycle JSON",
  () => {
    assert.doesNotMatch(
      workflowSource,
      /JSON\.stringify\(\s*ollamaResult\.investigationLifecycle/,
    );

    assert.doesNotMatch(
      workflowSource,
      /investigation_lifecycle_json/,
    );
  },
);

test(
  "workflow retains one IEL write call",
  () => {
    const matches =
      workflowSource.match(
        /createInterpretationEvidenceLedgerEntry\(/g,
      ) || [];

    assert.equal(matches.length, 1);
  },
);

test(
  "conversation-turn persistence remains lifecycle-independent",
  () => {
    const conversationRuntime = fs.readFileSync(
      "db/matilda-conversation-runtime.ts",
      "utf8",
    );

    assert.doesNotMatch(
      conversationRuntime,
      /investigationLifecycle|investigation_lifecycle/,
    );
  },
);

test(
  "Conversation Context Runtime remains lifecycle-independent",
  () => {
    const contextRuntime = fs.readFileSync(
      "server/matilda-conversation-context-runtime.ts",
      "utf8",
    );

    assert.doesNotMatch(
      contextRuntime,
      /investigationLifecycle|investigation_lifecycle/,
    );
  },
);

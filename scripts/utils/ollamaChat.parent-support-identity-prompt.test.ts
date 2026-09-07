import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "project-context support provenance is reconstructed instead of model-authored",
  () => {
    assert.match(
      source,
      /Project-context child identity and parent support provenance are reconstructed deterministically by runtime from validated candidate positions\./,
    );
    assert.match(
      source,
      /Do not return project_context_excerpt entries in supportSourceReferences\./,
    );
  },
);

test(
  "project semantic selection and conversation support provenance remain distinct",
  () => {
    assert.match(
      source,
      /Set selectedContextCandidatePositions to the integer candidate positions of exactly the supplied project-context child segments whose content materially affects the immediate reply\./,
    );
    assert.match(
      source,
      /Set supportSourceReferences to only supplied conversation turns that explicitly support the conclusion, recommendation, or assessment expressed in reply\./,
    );
    assert.match(source, /Segment candidate:/);
    assert.match(source, /parentRelativePath =/);
    assert.match(source, /parentLineNumber =/);
    assert.doesNotMatch(
      source,
      /For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence\./,
    );
  },
);

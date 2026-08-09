import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const source = fs.readFileSync(
  new URL("./ollamaChat.ts", import.meta.url),
  "utf8",
);

test(
  "project-context support is explicitly restricted to parent Source identities",
  () => {
    assert.match(
      source,
      /For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence\./,
    );

    assert.match(
      source,
      /Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity\./,
    );
  },
);

test(
  "existing parent support and child semantic identity instructions remain distinct",
  () => {
    assert.match(
      source,
      /For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied in bounded project context evidence\./,
    );

    assert.match(
      source,
      /Segment source:/,
    );

    assert.match(
      source,
      /selectedContextSegments/,
    );
  },
);

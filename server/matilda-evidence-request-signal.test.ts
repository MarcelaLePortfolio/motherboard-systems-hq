import assert from "node:assert/strict";
import test from "node:test";

import {
  isExplicitEvidenceRequest,
} from "./matilda-evidence-request-signal";

test(
  "recognizes bounded explicit repository evidence requests",
  () => {
    const requests = [
      "What evidence supports that?",
      "What evidence supports your conclusion?",
      "What repository evidence supports that?",
      "What repository evidence supports your recommendation?",
      "What repository evidence shows that?",
      "Show me the repository evidence.",
      "What evidence do we have in the repository?",
    ];

    for (const message of requests) {
      assert.equal(
        isExplicitEvidenceRequest(message),
        true,
        message,
      );
    }
  },
);

test(
  "rejects explanation, generic, implementation, and unrelated evidence requests",
  () => {
    const messages = [
      "",
      "Why?",
      "Why is that?",
      "Explain that.",
      "Please explain your conclusion.",
      "Tell me more",
      "Continue",
      "What should we do next?",
      "Can we implement this?",
      "What evidence supports photosynthesis?",
      "Show me evidence about climate change.",
      "What happened?",
      "Give me the engineering justification.",
    ];

    for (const message of messages) {
      assert.equal(
        isExplicitEvidenceRequest(message),
        false,
        message,
      );
    }
  },
);

test(
  "normalizes case and whitespace without broadening semantics",
  () => {
    assert.equal(
      isExplicitEvidenceRequest(
        "  WHAT REPOSITORY EVIDENCE SHOWS THAT?  ",
      ),
      true,
    );

    assert.equal(
      isExplicitEvidenceRequest(
        "  tell me more about the evidence  ",
      ),
      false,
    );
  },
);

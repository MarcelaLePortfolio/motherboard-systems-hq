import assert from "node:assert/strict";
import test from "node:test";

import {
  isExplicitExplanationRequest,
} from "./matilda-explanation-request-signal";

test(
  "recognizes bounded explicit explanation requests",
  () => {
    const requests = [
      "Why?",
      "Why is that?",
      "Why do you recommend that?",
      "Explain that.",
      "Please explain your conclusion.",
      "What evidence supports that?",
      "What supports your recommendation?",
      "Walk me through the tradeoffs.",
      "Walk me through the trade-offs.",
      "Give me the engineering justification.",
      "What is the engineering justification?",
    ];

    for (const message of requests) {
      assert.equal(
        isExplicitExplanationRequest(message),
        true,
        message,
      );
    }
  },
);

test(
  "rejects ambiguous or unrelated messages",
  () => {
    const messages = [
      "",
      "Continue",
      "Okay",
      "What should we do next?",
      "Which option is better?",
      "Can we implement this?",
      "Tell me more",
      "What happened?",
      "Why is the sky blue?",
      "Explain TypeScript generics.",
      "What evidence do we have in the repository?",
    ];

    for (const message of messages) {
      assert.equal(
        isExplicitExplanationRequest(message),
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
      isExplicitExplanationRequest(
        "  WHY DO YOU RECOMMEND THAT?  ",
      ),
      true,
    );

    assert.equal(
      isExplicitExplanationRequest(
        "  tell me more about that  ",
      ),
      false,
    );
  },
);

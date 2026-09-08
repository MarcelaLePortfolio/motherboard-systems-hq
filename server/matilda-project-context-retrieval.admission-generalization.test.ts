import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";

import {
  retrieveMatildaProjectContext,
} from "./matilda-project-context-retrieval";

const projectRootPath = path.resolve(
  import.meta.dirname,
  "..",
);

const vagueModificationRequests = [
  "I want to make changes to the frontend.",
  "I would like to work on the frontend.",
  "Can we do some work on the UI?",
  "I have a few things I want to do to the dashboard.",
  "Lets make the navigation better.",
  "I want to mess with the sidebar.",
  "There are some frontend things I want to fix.",
  "Can we improve the dashboard?",
  "I want to work on how the app looks.",
  "Lets do something with the navigation.",
];

const concreteModificationRequests = [
  "Rename Packages to Workspaces in the navigation.",
  "Remove the Packages tab from the sidebar.",
  "Move Packages below Settings in the sidebar.",
  "Hide the Packages tab when there are no packages.",
  "Add a Settings link underneath Workspace.",
  "The Packages button should open the Workspaces screen.",
];

const substantiveProjectQuestions = [
  "How does durable interpretation persistence work?",
  "Where is navigation state persisted?",
  "What owns the approval transition?",
];

test(
  "vague project modification requests remain below retrieval admission",
  () => {
    for (const message of vagueModificationRequests) {
      const result = retrieveMatildaProjectContext({
        projectId: "hq",
        projectRootPath,
        message,
      });

      assert.equal(
        result.searched,
        false,
        `Expected no retrieval for vague request: ${message}`,
      );
    }
  },
);

test(
  "concrete project modification requests remain retrieval eligible",
  () => {
    for (const message of concreteModificationRequests) {
      const result = retrieveMatildaProjectContext({
        projectId: "hq",
        projectRootPath,
        message,
      });

      assert.equal(
        result.searched,
        true,
        `Expected retrieval for concrete request: ${message}`,
      );
    }
  },
);

test(
  "substantive project questions remain retrieval eligible",
  () => {
    for (const message of substantiveProjectQuestions) {
      const result = retrieveMatildaProjectContext({
        projectId: "hq",
        projectRootPath,
        message,
      });

      assert.equal(
        result.searched,
        true,
        `Expected retrieval for substantive question: ${message}`,
      );
    }
  },
);

test(
  "explicit repository evidence requests remain retrieval eligible",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message:
        "What repository evidence shows that this workflow invokes ollamaChat?",
    });

    assert.equal(result.searched, true);
  },
);

test(
  "low-signal conversation remains below retrieval admission",
  () => {
    const result = retrieveMatildaProjectContext({
      projectId: "hq",
      projectRootPath,
      message: "Hey Matilda!",
    });

    assert.equal(result.searched, false);
  },
);

test(
  "repository verification requests are retrieval eligible while unrelated verification remains below admission",
  () => {
    const direct = [
      "Please verify the repository state before we proceed.",
      "Can you check the backend implementation?",
      "Confirm this is actually wired in the codebase.",
      "Please complete the underlying code/runtime verification.",
    ];

    for (const message of direct) {
      assert.equal(
        retrieveMatildaProjectContext({
          projectId: "hq",
          projectRootPath,
          message,
        }).searched,
        true,
      );
    }

    const unrelated = [
      "Verify the browser experience.",
      "Verify my email address.",
      "Verify the source of this quote.",
      "Check the file I uploaded.",
      "Verify the server address I gave you.",
      "Please validate this before continuing.",
    ];

    for (const message of unrelated) {
      assert.equal(
        retrieveMatildaProjectContext({
          projectId: "hq",
          projectRootPath,
          message,
        }).searched,
        false,
      );
    }
  },
);

test(
  "bounded verification continuation inherits only an immediately prior repository verification request",
  () => {
    const priorUserMessage =
      "Please complete the underlying code/runtime verification.";

    for (const message of [
      "Are you still verifying this?",
      "Continue the verification.",
      "Did you finish the verification?",
      "Have you completed that check?",
    ]) {
      assert.equal(
        retrieveMatildaProjectContext({
          projectId: "hq",
          projectRootPath,
          priorUserMessage,
          message,
        }).searched,
        true,
      );
    }

    const negativeCases = [
      [
        "Please proceed with the browser validation.",
        "Are you still verifying this?",
      ],
      [
        "Please verify my email address.",
        "Are you still verifying this?",
      ],
      [
        "I want to make changes to the frontend.",
        "Did you finish the verification?",
      ],
      [
        "Verify the runtime implementation.",
        "Continue",
      ],
      [
        "Verify the runtime implementation.",
        "Continue the browser validation",
      ],
      [
        "Verify the runtime implementation.",
        "What about this?",
      ],
    ];

    for (const [priorUserMessage, message] of negativeCases) {
      assert.equal(
        retrieveMatildaProjectContext({
          projectId: "hq",
          projectRootPath,
          priorUserMessage,
          message,
        }).searched,
        false,
      );
    }
  },
);

#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT GOVERNED LOCAL COMMIT EFFECT UNIT ==="
echo "MODE=EXECUTION"
echo "SCOPE=NEW_NARROW_EFFECT_ADAPTER_AND_TEMP_REPO_SMOKE_ONLY"
echo "GENERIC_CADE_EXECUTOR_CHANGE=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"
echo "REMOTE_PUSH_EFFECT=NO"

EXPECTED_HEAD_PREFIX="e2e78810f"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

cat > server/cade/cade-version-control-effects.ts << 'FILEEOF'
import path from "node:path";
import { execFileSync } from "node:child_process";

export type GovernedLocalCommitInput = {
  repoPath: string;
  branch: string;
  expectedHead: string;
  allowedPaths: string[];
  commitMessage: string;
  approvalId: string;
  envelopeId: string;
  executionId: string;
  commitAuthorized: boolean;
  pushAuthorized: boolean;
};

export type GovernedLocalCommitResult = {
  status: "ok";
  preHead: string;
  postHead: string;
  branch: string;
  committedFiles: string[];
  commitMessage: string;
  approvalId: string;
  envelopeId: string;
  executionId: string;
  remoteEffect: false;
  pushEffect: false;
};

function fail(code: string, message: string): never {
  const err = new Error(message) as Error & { code?: string };
  err.code = code;
  throw err;
}

function git(
  repoPath: string,
  args: string[],
): string {
  return execFileSync(
    "git",
    args,
    {
      cwd: repoPath,
      encoding: "utf8",
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    },
  ).trim();
}

function normalizeRepoPath(repoPath: string): string {
  return path.resolve(repoPath);
}

function normalizePath(value: string): string {
  return value.replaceAll("\\", "/").replace(/^\.\/+/, "");
}

function uniqueSorted(values: string[]): string[] {
  return [...new Set(values)].sort();
}

function parseNameOnly(output: string): string[] {
  if (!output.trim()) {
    return [];
  }

  return uniqueSorted(
    output
      .split(/\r?\n/)
      .map((entry) => normalizePath(entry.trim()))
      .filter(Boolean),
  );
}

function assertRequiredInput(
  input: GovernedLocalCommitInput,
): void {
  if (!input || typeof input !== "object") {
    fail(
      "INVALID_LOCAL_COMMIT_INPUT",
      "governed local commit input required",
    );
  }

  const requiredStrings: Array<
    [keyof GovernedLocalCommitInput, string]
  > = [
    ["repoPath", "repo_path required"],
    ["branch", "branch required"],
    ["expectedHead", "expected_head required"],
    ["commitMessage", "commit_message required"],
    ["approvalId", "approval_id required"],
    ["envelopeId", "envelope_id required"],
    ["executionId", "execution_id required"],
  ];

  for (const [key, message] of requiredStrings) {
    const value = input[key];

    if (
      typeof value !== "string" ||
      value.trim().length === 0
    ) {
      fail("LOCAL_COMMIT_INPUT_REQUIRED", message);
    }
  }

  if (!/^[0-9a-f]{40}$/i.test(input.expectedHead)) {
    fail(
      "INVALID_EXPECTED_HEAD",
      "expected_head must be a 40-character git commit SHA",
    );
  }

  if (
    !Array.isArray(input.allowedPaths) ||
    input.allowedPaths.length === 0 ||
    input.allowedPaths.some(
      (entry) =>
        typeof entry !== "string" ||
        entry.trim().length === 0,
    )
  ) {
    fail(
      "ALLOWED_PATHS_REQUIRED",
      "non-empty allowed_paths required",
    );
  }

  if (input.commitAuthorized !== true) {
    fail(
      "COMMIT_AUTHORITY_REQUIRED",
      "commit_authorized=true required",
    );
  }

  if (input.pushAuthorized === true) {
    fail(
      "PUSH_AUTHORITY_PROHIBITED",
      "push_authorized must remain false for local commit effect",
    );
  }
}

function assertRepositoryRoot(
  repoPath: string,
): void {
  let resolvedRoot: string;

  try {
    resolvedRoot = normalizeRepoPath(
      git(repoPath, ["rev-parse", "--show-toplevel"]),
    );
  } catch {
    fail(
      "NOT_A_GIT_REPOSITORY",
      "repo_path must resolve to a Git repository root",
    );
  }

  if (resolvedRoot !== normalizeRepoPath(repoPath)) {
    fail(
      "REPOSITORY_ROOT_MISMATCH",
      "repo_path must equal resolved Git repository root",
    );
  }
}

function assertHead(
  repoPath: string,
  expectedHead: string,
): void {
  const actualHead = git(repoPath, [
    "rev-parse",
    "HEAD",
  ]);

  if (actualHead !== expectedHead) {
    fail(
      "EXPECTED_HEAD_MISMATCH",
      `expected HEAD ${expectedHead} but found ${actualHead}`,
    );
  }
}

function assertBranch(
  repoPath: string,
  expectedBranch: string,
): void {
  const branch = git(repoPath, [
    "branch",
    "--show-current",
  ]);

  if (branch !== expectedBranch) {
    fail(
      "BRANCH_MISMATCH",
      `expected branch ${expectedBranch} but found ${branch}`,
    );
  }
}

function trackedDirtyPaths(
  repoPath: string,
): string[] {
  return parseNameOnly(
    git(repoPath, [
      "diff",
      "--name-only",
      "HEAD",
      "--",
    ]),
  );
}

function stagedPaths(
  repoPath: string,
): string[] {
  return parseNameOnly(
    git(repoPath, [
      "diff",
      "--cached",
      "--name-only",
      "--",
    ]),
  );
}

function isPathAllowed(
  file: string,
  allowedPaths: string[],
): boolean {
  const normalized = normalizePath(file);

  return allowedPaths.some((allowed) => {
    const candidate = normalizePath(allowed);

    if (candidate.endsWith("/")) {
      return normalized.startsWith(candidate);
    }

    return normalized === candidate;
  });
}

function assertAuthorizedTrackedPaths(
  repoPath: string,
  allowedPaths: string[],
): string[] {
  const dirty = trackedDirtyPaths(repoPath);

  const unauthorized = dirty.filter(
    (file) => !isPathAllowed(file, allowedPaths),
  );

  if (unauthorized.length > 0) {
    fail(
      "UNAUTHORIZED_TRACKED_CHANGE",
      `unauthorized tracked changes: ${unauthorized.join(", ")}`,
    );
  }

  return dirty;
}

function assertAuthorizedPreexistingStaging(
  repoPath: string,
  allowedPaths: string[],
): string[] {
  const staged = stagedPaths(repoPath);

  const unauthorized = staged.filter(
    (file) => !isPathAllowed(file, allowedPaths),
  );

  if (unauthorized.length > 0) {
    fail(
      "UNAUTHORIZED_STAGED_PATH",
      `unauthorized staged paths: ${unauthorized.join(", ")}`,
    );
  }

  return staged;
}

function stageExplicitPaths(
  repoPath: string,
  paths: string[],
): void {
  if (paths.length === 0) {
    fail(
      "NO_AUTHORIZED_CHANGES",
      "no authorized tracked changes available to commit",
    );
  }

  git(repoPath, [
    "add",
    "--",
    ...paths,
  ]);
}

function assertExactStagedSet(
  repoPath: string,
  expectedPaths: string[],
): string[] {
  const actual = stagedPaths(repoPath);
  const expected = uniqueSorted(
    expectedPaths.map(normalizePath),
  );

  if (
    actual.length !== expected.length ||
    actual.some(
      (entry, index) => entry !== expected[index],
    )
  ) {
    fail(
      "STAGED_SET_MISMATCH",
      `staged set ${JSON.stringify(actual)} does not equal authorized set ${JSON.stringify(expected)}`,
    );
  }

  return actual;
}

function committedPaths(
  repoPath: string,
): string[] {
  return parseNameOnly(
    git(repoPath, [
      "diff-tree",
      "--no-commit-id",
      "--name-only",
      "-r",
      "HEAD",
      "--",
    ]),
  );
}

export function performGovernedLocalCommit(
  input: GovernedLocalCommitInput,
): GovernedLocalCommitResult {
  assertRequiredInput(input);

  const repoPath = normalizeRepoPath(input.repoPath);
  const allowedPaths = uniqueSorted(
    input.allowedPaths.map(normalizePath),
  );

  assertRepositoryRoot(repoPath);
  assertHead(repoPath, input.expectedHead);
  assertBranch(repoPath, input.branch);

  const authorizedDirtyPaths =
    assertAuthorizedTrackedPaths(
      repoPath,
      allowedPaths,
    );

  assertAuthorizedPreexistingStaging(
    repoPath,
    allowedPaths,
  );

  stageExplicitPaths(
    repoPath,
    authorizedDirtyPaths,
  );

  const staged =
    assertExactStagedSet(
      repoPath,
      authorizedDirtyPaths,
    );

  const preHead = git(repoPath, [
    "rev-parse",
    "HEAD",
  ]);

  git(repoPath, [
    "commit",
    "-m",
    input.commitMessage,
    "--",
  ]);

  const postHead = git(repoPath, [
    "rev-parse",
    "HEAD",
  ]);

  if (postHead === preHead) {
    fail(
      "POST_COMMIT_HEAD_UNCHANGED",
      "local commit did not advance HEAD",
    );
  }

  const parent = git(repoPath, [
    "rev-parse",
    "HEAD^",
  ]);

  if (parent !== preHead) {
    fail(
      "POST_COMMIT_PARENT_MISMATCH",
      "new commit parent does not equal pre-commit HEAD",
    );
  }

  const branch = git(repoPath, [
    "branch",
    "--show-current",
  ]);

  if (branch !== input.branch) {
    fail(
      "POST_COMMIT_BRANCH_MISMATCH",
      "active branch changed during local commit",
    );
  }

  const committed = committedPaths(repoPath);

  if (
    committed.length !== staged.length ||
    committed.some(
      (entry, index) => entry !== staged[index],
    )
  ) {
    fail(
      "COMMITTED_PATH_SET_MISMATCH",
      "committed files do not equal authorized staged files",
    );
  }

  return {
    status: "ok",
    preHead,
    postHead,
    branch,
    committedFiles: committed,
    commitMessage: input.commitMessage,
    approvalId: input.approvalId,
    envelopeId: input.envelopeId,
    executionId: input.executionId,
    remoteEffect: false,
    pushEffect: false,
  };
}
FILEEOF

cat > server/execution/cade-governed-commit-adapter.ts << 'FILEEOF'
import {
  performGovernedLocalCommit,
  type GovernedLocalCommitResult,
} from "../cade/cade-version-control-effects";
import { recordExecutionEvent } from "../cade/cade-event-wrapper";

type GovernedCommitEnvelope = {
  identity?: {
    envelope_id?: string | null;
  };
  project_target?: {
    repo_path?: string | null;
    branch?: string | null;
    expected_head?: string | null;
  };
  mutation_scope?: {
    allowed_paths?: string[];
  };
};

type GovernedCommitApproval = {
  approval_artifact?: {
    approval_id?: string | null;
  };
  version_control_authorization?: {
    commit_authorized?: boolean;
    push_authorized?: boolean;
  };
};

export function executeGovernedLocalCommit({
  envelope,
  approvalGate,
  executionId,
  commitMessage,
}: {
  envelope: GovernedCommitEnvelope;
  approvalGate: GovernedCommitApproval;
  executionId: string;
  commitMessage: string;
}): GovernedLocalCommitResult {
  if (
    approvalGate
      ?.version_control_authorization
      ?.commit_authorized !== true
  ) {
    throw new Error(
      "governed commit adapter requires commit_authorized=true",
    );
  }

  if (
    approvalGate
      ?.version_control_authorization
      ?.push_authorized === true
  ) {
    throw new Error(
      "governed commit adapter refuses push_authorized=true",
    );
  }

  const approvalId =
    approvalGate?.approval_artifact?.approval_id;

  const envelopeId =
    envelope?.identity?.envelope_id;

  const repoPath =
    envelope?.project_target?.repo_path;

  const branch =
    envelope?.project_target?.branch;

  const expectedHead =
    envelope?.project_target?.expected_head;

  const allowedPaths =
    envelope?.mutation_scope?.allowed_paths;

  if (!approvalId) {
    throw new Error(
      "governed commit adapter requires approval_id",
    );
  }

  if (!envelopeId) {
    throw new Error(
      "governed commit adapter requires envelope_id",
    );
  }

  if (!executionId) {
    throw new Error(
      "governed commit adapter requires execution_id",
    );
  }

  if (!repoPath) {
    throw new Error(
      "governed commit adapter requires repo_path",
    );
  }

  if (!branch) {
    throw new Error(
      "governed commit adapter requires branch",
    );
  }

  if (!expectedHead) {
    throw new Error(
      "governed commit adapter requires expected_head",
    );
  }

  if (
    !Array.isArray(allowedPaths) ||
    allowedPaths.length === 0
  ) {
    throw new Error(
      "governed commit adapter requires allowed_paths",
    );
  }

  if (!commitMessage) {
    throw new Error(
      "governed commit adapter requires commit_message",
    );
  }

  const result = performGovernedLocalCommit({
    repoPath,
    branch,
    expectedHead,
    allowedPaths,
    commitMessage,
    approvalId,
    envelopeId,
    executionId,
    commitAuthorized: true,
    pushAuthorized: false,
  });

  recordExecutionEvent({
    id: executionId,
    action: "commit_changes",
    input: {
      repo_path: repoPath,
      branch,
      expected_head: expectedHead,
      approval_id: approvalId,
      envelope_id: envelopeId,
      execution_id: executionId,
      commit_message: commitMessage,
    },
    output: {
      pre_head: result.preHead,
      post_head: result.postHead,
      committed_files: result.committedFiles,
      commit_message: result.commitMessage,
      remote_effect: false,
      push_effect: false,
    },
    affectedFiles: result.committedFiles,
  });

  return result;
}
FILEEOF

cat > server/execution/smoke-test-governed-local-commit.ts << 'FILEEOF'
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";

import { performGovernedLocalCommit } from "../cade/cade-version-control-effects";

function git(
  repo: string,
  args: string[],
): string {
  return execFileSync(
    "git",
    args,
    {
      cwd: repo,
      encoding: "utf8",
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    },
  ).trim();
}

function createRepo(): {
  root: string;
  branch: string;
  head: string;
} {
  const root = fs.mkdtempSync(
    path.join(
      os.tmpdir(),
      "cade-governed-commit-",
    ),
  );

  git(root, ["init"]);
  git(root, [
    "config",
    "user.email",
    "cade-smoke@example.invalid",
  ]);
  git(root, [
    "config",
    "user.name",
    "Cade Smoke",
  ]);

  fs.writeFileSync(
    path.join(root, "authorized.txt"),
    "base\n",
  );

  fs.writeFileSync(
    path.join(root, "protected.txt"),
    "protected\n",
  );

  git(root, [
    "add",
    "--",
    "authorized.txt",
    "protected.txt",
  ]);

  git(root, [
    "commit",
    "-m",
    "Initial smoke fixture",
    "--",
  ]);

  return {
    root,
    branch: git(root, [
      "branch",
      "--show-current",
    ]),
    head: git(root, [
      "rev-parse",
      "HEAD",
    ]),
  };
}

function runAuthorizedCommitTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  fs.writeFileSync(
    path.join(repo.root, "unrelated.tmp"),
    "untracked\n",
  );

  const result = performGovernedLocalCommit({
    repoPath: repo.root,
    branch: repo.branch,
    expectedHead: repo.head,
    allowedPaths: ["authorized.txt"],
    commitMessage: "Governed local commit smoke",
    approvalId: "approval-smoke",
    envelopeId: "envelope-smoke",
    executionId: "execution-smoke",
    commitAuthorized: true,
    pushAuthorized: false,
  });

  assert.equal(result.status, "ok");
  assert.equal(result.preHead, repo.head);
  assert.notEqual(result.postHead, repo.head);
  assert.equal(
    git(repo.root, [
      "rev-parse",
      "HEAD^",
    ]),
    repo.head,
  );
  assert.deepEqual(
    result.committedFiles,
    ["authorized.txt"],
  );
  assert.equal(
    fs.existsSync(
      path.join(repo.root, "unrelated.tmp"),
    ),
    true,
  );

  const status = git(repo.root, [
    "status",
    "--short",
  ]);

  assert.match(
    status,
    /\?\? unrelated\.tmp/,
  );
}

function runHeadMismatchTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: repo.branch,
        expectedHead: "a".repeat(40),
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: true,
        pushAuthorized: false,
      }),
    /expected HEAD/,
  );

  assert.equal(
    git(repo.root, [
      "diff",
      "--cached",
      "--name-only",
    ]),
    "",
  );
}

function runBranchMismatchTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: "not-the-current-branch",
        expectedHead: repo.head,
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: true,
        pushAuthorized: false,
      }),
    /expected branch/,
  );

  assert.equal(
    git(repo.root, [
      "diff",
      "--cached",
      "--name-only",
    ]),
    "",
  );
}

function runUnauthorizedTrackedChangeTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  fs.writeFileSync(
    path.join(repo.root, "protected.txt"),
    "unauthorized\n",
  );

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: repo.branch,
        expectedHead: repo.head,
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: true,
        pushAuthorized: false,
      }),
    /unauthorized tracked changes/,
  );

  assert.equal(
    git(repo.root, [
      "diff",
      "--cached",
      "--name-only",
    ]),
    "",
  );
}

function runUnauthorizedStagedTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  fs.writeFileSync(
    path.join(repo.root, "protected.txt"),
    "staged unauthorized\n",
  );

  git(repo.root, [
    "add",
    "--",
    "protected.txt",
  ]);

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: repo.branch,
        expectedHead: repo.head,
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: true,
        pushAuthorized: false,
      }),
    /unauthorized tracked changes|unauthorized staged paths/,
  );
}

function runCommitAuthorityTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: repo.branch,
        expectedHead: repo.head,
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: false,
        pushAuthorized: false,
      }),
    /commit_authorized=true required/,
  );
}

function runPushAuthorityTest(): void {
  const repo = createRepo();

  fs.writeFileSync(
    path.join(repo.root, "authorized.txt"),
    "changed\n",
  );

  assert.throws(
    () =>
      performGovernedLocalCommit({
        repoPath: repo.root,
        branch: repo.branch,
        expectedHead: repo.head,
        allowedPaths: ["authorized.txt"],
        commitMessage: "Must fail",
        approvalId: "approval-smoke",
        envelopeId: "envelope-smoke",
        executionId: "execution-smoke",
        commitAuthorized: true,
        pushAuthorized: true,
      }),
    /push_authorized must remain false/,
  );
}

runAuthorizedCommitTest();
runHeadMismatchTest();
runBranchMismatchTest();
runUnauthorizedTrackedChangeTest();
runUnauthorizedStagedTest();
runCommitAuthorityTest();
runPushAuthorityTest();

console.log(
  JSON.stringify(
    {
      ok: true,
      valid_local_commit: true,
      expected_head_guard: true,
      branch_guard: true,
      unauthorized_tracked_guard: true,
      unrelated_untracked_preserved: true,
      unauthorized_staged_guard: true,
      commit_authority_guard: true,
      push_authority_guard: true,
      parent_verification: true,
      remote_effect: false,
      generic_shell: false,
      active_project_history_touched: false,
    },
    null,
    2,
  ),
);
FILEEOF

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== TEMP-REPOSITORY GOVERNED LOCAL COMMIT SMOKE ==="
npx tsx server/execution/smoke-test-governed-local-commit.ts
echo "LOCAL_COMMIT_SMOKE=PASS"

echo
echo "=== VERIFY GENERIC EXECUTOR AND ROUTES UNCHANGED ==="
if git diff -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  | grep -q .; then
  echo "STOP: prohibited existing authority surface changed"
  exit 1
fi
echo "GENERIC_EXECUTION_SURFACES_UNCHANGED=YES"

echo
echo "=== VERIFY NO PUSH OR SHELL PROCESS CONTRACT ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const effect = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(
  effect,
  /execFileSync/,
);

assert.match(
  effect,
  /shell:\s*false/,
);

assert.doesNotMatch(
  effect,
  /\bexecSync\s*\(/,
);

assert.doesNotMatch(
  effect,
  /\bspawn\s*\(/,
);

assert.doesNotMatch(
  effect,
  /["']push["']/,
);

assert.doesNotMatch(
  effect,
  /--force/,
);

assert.doesNotMatch(
  effect,
  /git add \./,
);

console.log("PROCESS_BOUNDARY=PASS");
NODE

echo
echo "=== VERIFY AUTHORIZED PATCH SET ONLY ==="
AUTHORIZED_FILES=(
  server/cade/cade-version-control-effects.ts
  server/execution/cade-governed-commit-adapter.ts
  server/execution/smoke-test-governed-local-commit.ts
)

if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

git add "${AUTHORIZED_FILES[@]}"

EXPECTED="$(
  printf '%s\n' "${AUTHORIZED_FILES[@]}" | sort
)"

ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized local commit unit"
  git reset
  exit 1
fi

git commit -m "Add governed Cade local commit effect"
git push

echo
echo "GOVERNED_LOCAL_COMMIT_EFFECT_UNIT=COMMITTED_AND_PUSHED"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "REMOTE_PUSH_EFFECT=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_LOCAL_COMMIT_EFFECT_CLOSURE_BEFORE_CLASSIFYING_PUSH_SUCCESSOR"

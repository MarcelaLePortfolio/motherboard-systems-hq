import fs from "node:fs";
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
  const resolved = path.resolve(repoPath);

  try {
    return fs.realpathSync.native(resolved);
  } catch {
    return fs.realpathSync(resolved);
  }
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

export type GovernedRemotePushInput = {
  repoPath: string;
  branch: string;
  remote: string;
  expectedLocalHead: string;
  expectedRemoteUrl: string;
  approvalId: string;
  envelopeId: string;
  executionId: string;
  commitAuthorized: boolean;
  pushAuthorized: boolean;
};

export type GovernedRemotePushResult = {
  status: "ok";
  localHead: string;
  branch: string;
  remote: string;
  remoteUrl: string;
  preRemoteHead: string | null;
  postRemoteHead: string;
  approvalId: string;
  envelopeId: string;
  executionId: string;
  remoteEffect: true;
  pushEffect: true;
  forceEffect: false;
};

function remoteHead(
  repoPath: string,
  remote: string,
  branch: string,
): string | null {
  const output = git(repoPath, [
    "ls-remote",
    remote,
    `refs/heads/${branch}`,
  ]);

  if (!output) {
    return null;
  }

  const [head] = output.split(/\s+/);

  return head || null;
}

export function performGovernedRemotePush(
  input: GovernedRemotePushInput,
): GovernedRemotePushResult {
  if (!input || typeof input !== "object") {
    fail(
      "INVALID_REMOTE_PUSH_INPUT",
      "governed remote push input required",
    );
  }

  for (const [value, message] of [
    [input.repoPath, "repo_path required"],
    [input.branch, "branch required"],
    [input.remote, "remote required"],
    [input.expectedLocalHead, "expected_local_head required"],
    [input.expectedRemoteUrl, "expected_remote_url required"],
    [input.approvalId, "approval_id required"],
    [input.envelopeId, "envelope_id required"],
    [input.executionId, "execution_id required"],
  ]) {
    if (
      typeof value !== "string" ||
      value.trim().length === 0
    ) {
      fail(
        "REMOTE_PUSH_INPUT_REQUIRED",
        message,
      );
    }
  }

  if (input.commitAuthorized !== true) {
    fail(
      "REMOTE_PUSH_COMMIT_AUTHORITY_REQUIRED",
      "commit_authorized=true required",
    );
  }

  if (input.pushAuthorized !== true) {
    fail(
      "REMOTE_PUSH_AUTHORITY_REQUIRED",
      "push_authorized=true required",
    );
  }

  if (
    !/^[0-9a-f]{40}$/i.test(
      input.expectedLocalHead,
    )
  ) {
    fail(
      "INVALID_EXPECTED_LOCAL_HEAD",
      "expected_local_head must be a 40-character SHA",
    );
  }

  const repoPath =
    normalizeRepoPath(input.repoPath);

  assertRepositoryRoot(repoPath);

  const localHead = git(repoPath, [
    "rev-parse",
    "HEAD",
  ]);

  if (
    localHead !==
    input.expectedLocalHead
  ) {
    fail(
      "REMOTE_PUSH_LOCAL_HEAD_MISMATCH",
      `expected local HEAD ${input.expectedLocalHead} but found ${localHead}`,
    );
  }

  const branch = git(repoPath, [
    "branch",
    "--show-current",
  ]);

  if (branch !== input.branch) {
    fail(
      "REMOTE_PUSH_BRANCH_MISMATCH",
      `expected branch ${input.branch} but found ${branch}`,
    );
  }

  const trackedDirty = trackedDirtyPaths(
    repoPath,
  );

  if (trackedDirty.length > 0) {
    fail(
      "REMOTE_PUSH_TRACKED_DRIFT",
      `tracked worktree drift blocks push: ${trackedDirty.join(", ")}`,
    );
  }

  const staged = stagedPaths(repoPath);

  if (staged.length > 0) {
    fail(
      "REMOTE_PUSH_STAGED_SET_NOT_EMPTY",
      `staged paths block push: ${staged.join(", ")}`,
    );
  }

  const remoteUrl = git(repoPath, [
    "remote",
    "get-url",
    input.remote,
  ]);

  if (
    normalizeRepoPath(remoteUrl) !==
    normalizeRepoPath(
      input.expectedRemoteUrl,
    )
  ) {
    fail(
      "REMOTE_PUSH_URL_MISMATCH",
      "observed remote URL does not match authorized remote URL",
    );
  }

  const preRemoteHead = remoteHead(
    repoPath,
    input.remote,
    input.branch,
  );

  git(repoPath, [
    "push",
    input.remote,
    `HEAD:refs/heads/${input.branch}`,
  ]);

  const postRemoteHead = remoteHead(
    repoPath,
    input.remote,
    input.branch,
  );

  if (
    postRemoteHead !==
    input.expectedLocalHead
  ) {
    fail(
      "REMOTE_PUSH_POST_VERIFY_FAILED",
      "remote head does not equal expected local head after push",
    );
  }

  const localHeadAfter = git(repoPath, [
    "rev-parse",
    "HEAD",
  ]);

  if (
    localHeadAfter !==
    input.expectedLocalHead
  ) {
    fail(
      "REMOTE_PUSH_LOCAL_HEAD_CHANGED",
      "local HEAD changed during push",
    );
  }

  const branchAfter = git(repoPath, [
    "branch",
    "--show-current",
  ]);

  if (branchAfter !== input.branch) {
    fail(
      "REMOTE_PUSH_LOCAL_BRANCH_CHANGED",
      "local branch changed during push",
    );
  }

  return {
    status: "ok",
    localHead:
      input.expectedLocalHead,
    branch: input.branch,
    remote: input.remote,
    remoteUrl,
    preRemoteHead,
    postRemoteHead,
    approvalId: input.approvalId,
    envelopeId: input.envelopeId,
    executionId: input.executionId,
    remoteEffect: true,
    pushEffect: true,
    forceEffect: false,
  };
}

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

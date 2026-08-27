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

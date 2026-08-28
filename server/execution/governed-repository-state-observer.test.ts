import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import test from "node:test";

import {
  observeGovernedRepositoryState,
} from "./governed-repository-state-observer";

function git(cwd: string, args: string[]): string {
  return execFileSync("git", args, {
    cwd,
    encoding: "utf8",
    shell: false,
  }).trim();
}

test("observes repository coordinates without mutation", () => {
  const root = fs.mkdtempSync(
    path.join(os.tmpdir(), "governed-repository-observer-"),
  );

  git(root, ["init"]);
  git(root, ["config", "user.email", "observer@example.test"]);
  git(root, ["config", "user.name", "Observer Test"]);
  git(root, ["checkout", "-b", "feature/observer-test"]);

  fs.writeFileSync(path.join(root, "README.md"), "observer\n");
  git(root, ["add", "README.md"]);
  git(root, ["commit", "-m", "fixture"]);
  git(root, ["remote", "add", "origin", root]);

  const beforeHead = git(root, ["rev-parse", "HEAD"]);
  const beforeStatus = git(root, ["status", "--porcelain"]);

  const observed = observeGovernedRepositoryState({
    repoPath: root,
  });

  assert.equal(observed.repo_path, fs.realpathSync(root));
  assert.equal(observed.expected_head, beforeHead);
  assert.equal(observed.branch, "feature/observer-test");
  assert.equal(observed.remote_url, root);

  assert.equal(git(root, ["rev-parse", "HEAD"]), beforeHead);
  assert.equal(git(root, ["status", "--porcelain"]), beforeStatus);
});

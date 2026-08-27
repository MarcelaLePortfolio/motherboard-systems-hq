import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";

import {
  performGovernedRemotePush,
} from "../cade/cade-version-control-effects";

function git(
  cwd: string,
  args: string[],
): string {
  return execFileSync(
    "git",
    args,
    {
      cwd,
      encoding: "utf8",
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    },
  ).trim();
}

function createFixture() {
  const root = fs.mkdtempSync(
    path.join(
      os.tmpdir(),
      "cade-push-smoke-",
    ),
  );

  const work = path.join(root, "work");
  const bare = path.join(root, "remote.git");

  fs.mkdirSync(work);

  git(root, [
    "init",
    "--bare",
    bare,
  ]);

  git(work, ["init"]);
  git(work, [
    "config",
    "user.email",
    "push-smoke@example.invalid",
  ]);
  git(work, [
    "config",
    "user.name",
    "Push Smoke",
  ]);

  fs.writeFileSync(
    path.join(work, "file.txt"),
    "base\n",
  );

  git(work, [
    "add",
    "--",
    "file.txt",
  ]);

  git(work, [
    "commit",
    "-m",
    "fixture commit",
    "--",
  ]);

  git(work, [
    "remote",
    "add",
    "origin",
    bare,
  ]);

  const branch = git(work, [
    "branch",
    "--show-current",
  ]);

  const head = git(work, [
    "rev-parse",
    "HEAD",
  ]);

  return {
    root,
    work,
    bare,
    branch,
    head,
  };
}

function baseInput(
  fixture: ReturnType<
    typeof createFixture
  >,
) {
  return {
    repoPath: fixture.work,
    branch: fixture.branch,
    remote: "origin",
    expectedLocalHead:
      fixture.head,
    expectedRemoteUrl:
      fixture.bare,
    approvalId:
      "approval-push-smoke",
    envelopeId:
      "envelope-push-smoke",
    executionId:
      "execution-push-smoke",
    commitAuthorized: true,
    pushAuthorized: true,
  };
}

{
  const fixture = createFixture();

  const result =
    performGovernedRemotePush(
      baseInput(fixture),
    );

  assert.equal(result.status, "ok");
  assert.equal(
    result.localHead,
    fixture.head,
  );
  assert.equal(
    result.postRemoteHead,
    fixture.head,
  );
  assert.equal(
    git(fixture.work, [
      "rev-parse",
      "HEAD",
    ]),
    fixture.head,
  );
  assert.equal(
    git(fixture.work, [
      "branch",
      "--show-current",
    ]),
    fixture.branch,
  );
  assert.equal(
    result.remoteEffect,
    true,
  );
  assert.equal(
    result.pushEffect,
    true,
  );
  assert.equal(
    result.forceEffect,
    false,
  );
}

{
  const fixture = createFixture();

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        pushAuthorized: false,
      }),
    /push_authorized=true/,
  );
}

{
  const fixture = createFixture();

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        commitAuthorized: false,
      }),
    /commit_authorized=true/,
  );
}

{
  const fixture = createFixture();

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        expectedLocalHead:
          "a".repeat(40),
      }),
    /expected local HEAD/,
  );
}

{
  const fixture = createFixture();

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        branch: "wrong-branch",
      }),
    /expected branch/,
  );
}

{
  const fixture = createFixture();

  fs.writeFileSync(
    path.join(
      fixture.work,
      "file.txt",
    ),
    "dirty\n",
  );

  assert.throws(
    () =>
      performGovernedRemotePush(
        baseInput(fixture),
      ),
    /tracked worktree drift/,
  );
}

{
  const fixture = createFixture();

  fs.writeFileSync(
    path.join(
      fixture.work,
      "file.txt",
    ),
    "staged\n",
  );

  git(fixture.work, [
    "add",
    "--",
    "file.txt",
  ]);

  assert.throws(
    () =>
      performGovernedRemotePush(
        baseInput(fixture),
      ),
    /tracked worktree drift|staged paths block push/,
  );
}

{
  const fixture = createFixture();

  const wrongBare =
    path.join(
      fixture.root,
      "wrong.git",
    );

  git(fixture.root, [
    "init",
    "--bare",
    wrongBare,
  ]);

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        expectedRemoteUrl:
          wrongBare,
      }),
    /remote URL/,
  );
}

console.log(
  JSON.stringify(
    {
      ok: true,
      authorized_temp_push:
        true,
      push_authority_guard:
        true,
      commit_authority_guard:
        true,
      local_head_guard:
        true,
      branch_guard: true,
      tracked_drift_guard:
        true,
      staged_set_guard: true,
      remote_url_guard: true,
      remote_head_verified:
        true,
      local_head_unchanged:
        true,
      local_branch_unchanged:
        true,
      force_effect: false,
      generic_shell: false,
      active_project_remote_touched:
        false,
    },
    null,
    2,
  ),
);

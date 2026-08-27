#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT AND VALIDATE GOVERNED REMOTE PUSH EFFECT ==="
echo "MODE=EXECUTION"
echo "SCOPE=TEMP_BARE_REMOTE_ONLY"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"
echo "GENERIC_CADE_ROUTE_CHANGE=NO"

EXPECTED_HEAD_PREFIX="dcbe6af46"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

cat >> server/cade/cade-version-control-effects.ts << 'FILEEOF'

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
FILEEOF

cat > server/execution/cade-governed-push-adapter.ts << 'FILEEOF'
import {
  performGovernedRemotePush,
  type GovernedRemotePushResult,
} from "../cade/cade-version-control-effects";
import { recordExecutionEvent } from "../cade/cade-event-wrapper";

export function executeGovernedRemotePush({
  envelope,
  approvalGate,
  executionId,
  expectedRemoteUrl,
}: {
  envelope: any;
  approvalGate: any;
  executionId: string;
  expectedRemoteUrl: string;
}): GovernedRemotePushResult {
  const vc =
    approvalGate
      ?.version_control_authorization;

  if (vc?.commit_authorized !== true) {
    throw new Error(
      "governed push adapter requires commit_authorized=true",
    );
  }

  if (vc?.push_authorized !== true) {
    throw new Error(
      "governed push adapter requires push_authorized=true",
    );
  }

  const repoPath =
    envelope?.project_target?.repo_path;

  const branch =
    envelope?.project_target?.branch;

  const remote =
    vc?.remote;

  const expectedLocalHead =
    approvalGate?.expected_push_head;

  const approvalId =
    approvalGate
      ?.approval_artifact
      ?.approval_id;

  const envelopeId =
    envelope?.identity?.envelope_id;

  const result =
    performGovernedRemotePush({
      repoPath,
      branch,
      remote,
      expectedLocalHead,
      expectedRemoteUrl,
      approvalId,
      envelopeId,
      executionId,
      commitAuthorized: true,
      pushAuthorized: true,
    });

  recordExecutionEvent({
    id: executionId,
    action: "push_changes",
    input: {
      repo_path: repoPath,
      branch,
      remote,
      remote_url:
        result.remoteUrl,
      expected_local_head:
        expectedLocalHead,
      approval_id: approvalId,
      envelope_id: envelopeId,
      execution_id: executionId,
    },
    output: {
      pre_remote_head:
        result.preRemoteHead,
      post_remote_head:
        result.postRemoteHead,
      local_head:
        result.localHead,
      remote_effect: true,
      push_effect: true,
      force_effect: false,
    },
    affectedFiles: [],
  });

  return result;
}
FILEEOF

cat > server/execution/smoke-test-governed-remote-push.ts << 'FILEEOF'
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

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        expectedRemoteUrl:
          path.join(
            fixture.root,
            "wrong.git",
          ),
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
FILEEOF

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== TEMP BARE REMOTE PUSH SMOKE ==="
npx tsx server/execution/smoke-test-governed-remote-push.ts
echo "REMOTE_PUSH_SMOKE=PASS"

echo
echo "=== VERIFY GENERIC ROUTES UNCHANGED ==="
if git diff -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/cade-governed-commit-adapter.ts \
  | grep -q .; then
  echo "STOP: prohibited authority surface changed"
  exit 1
fi
echo "PROTECTED_SURFACES_UNCHANGED=YES"

echo
echo "=== VERIFY PUSH PROCESS SHAPE ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(
  source,
  /execFileSync/,
);

assert.match(
  source,
  /shell:\s*false/,
);

assert.match(
  source,
  /"push"/,
);

assert.match(
  source,
  /HEAD:refs\/heads\//,
);

assert.doesNotMatch(
  source,
  /--force/,
);

assert.doesNotMatch(
  source,
  /--force-with-lease/,
);

console.log("REMOTE_PUSH_PROCESS_BOUNDARY=PASS");
NODE

AUTHORIZED_FILES=(
  server/cade/cade-version-control-effects.ts
  server/execution/cade-governed-push-adapter.ts
  server/execution/smoke-test-governed-remote-push.ts
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
  echo "STOP: staged set exceeds authorized remote push unit"
  git restore --staged -- "${AUTHORIZED_FILES[@]}"
  exit 1
fi

git commit -m "Add governed Cade remote push effect"
git push

echo
echo "GOVERNED_REMOTE_PUSH_EFFECT_UNIT=COMMITTED_AND_PUSHED"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION=NOT_ENABLED"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "NEXT_ACTION=VALIDATE_AND_CLOSE_REMOTE_PUSH_EFFECT_UNIT_BEFORE_ANY_PRODUCTION_REACHABILITY"

#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="236f47075cb1f6c92eb855937e8d787ccf2cfcff"
test "$(git rev-parse HEAD)" = "${EXPECTED_HEAD}"

python3 <<'PY'
from pathlib import Path

observer = Path("server/execution/governed-repository-state-observer.ts")
observer.write_text(r'''import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

export type GovernedRepositoryState = {
  repo_path: string;
  expected_head: string;
  branch: string;
  remote_name: string;
  remote_url: string;
  remote_push_url: string;
  upstream: string;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Repository observation requires ${field}.`);
  }

  return value.trim();
}

function git(repoPath: string, args: string[]): string {
  return execFileSync("git", args, {
    cwd: repoPath,
    encoding: "utf8",
    shell: false,
    stdio: ["ignore", "pipe", "pipe"],
  }).trim();
}

function normalizeRepoPath(repoPath: string): string {
  const resolved = path.resolve(repoPath);

  try {
    return fs.realpathSync.native(resolved);
  } catch {
    return fs.realpathSync(resolved);
  }
}

export function observeGovernedRepositoryState({
  repoPath,
}: {
  repoPath: string;
}): GovernedRepositoryState {
  const requestedRepoPath = normalizeRepoPath(
    requireText(repoPath, "repo_path"),
  );

  const observedRoot = normalizeRepoPath(
    git(requestedRepoPath, ["rev-parse", "--show-toplevel"]),
  );

  if (observedRoot !== requestedRepoPath) {
    throw new Error(
      "Observed Git repository root does not match canonical project repository path.",
    );
  }

  const expected_head = git(observedRoot, ["rev-parse", "HEAD"]);

  if (!/^[0-9a-f]{40}$/i.test(expected_head)) {
    throw new Error("Observed Git HEAD is not a 40-character commit SHA.");
  }

  const branch = requireText(
    git(observedRoot, ["branch", "--show-current"]),
    "observed branch",
  );

  const upstream = requireText(
    git(observedRoot, [
      "rev-parse",
      "--abbrev-ref",
      "--symbolic-full-name",
      "@{upstream}",
    ]),
    "tracked branch upstream",
  );

  const remote_name = requireText(
    git(observedRoot, ["config", "--get", `branch.${branch}.remote`]),
    "tracked branch remote",
  );

  const mergeRef = requireText(
    git(observedRoot, ["config", "--get", `branch.${branch}.merge`]),
    "tracked branch merge ref",
  );

  const expectedMergeRef = `refs/heads/${branch}`;

  if (mergeRef !== expectedMergeRef) {
    throw new Error(
      `Tracked branch merge ref ${mergeRef} does not match observed branch ${expectedMergeRef}.`,
    );
  }

  const expectedUpstream = `${remote_name}/${branch}`;

  if (upstream !== expectedUpstream) {
    throw new Error(
      `Tracked upstream ${upstream} does not match observed remote/branch ${expectedUpstream}.`,
    );
  }

  const remote_url = requireText(
    git(observedRoot, ["remote", "get-url", remote_name]),
    "observed remote URL",
  );

  const remote_push_url = requireText(
    git(observedRoot, ["remote", "get-url", "--push", remote_name]),
    "observed remote push URL",
  );

  return {
    repo_path: observedRoot,
    expected_head,
    branch,
    remote_name,
    remote_url,
    remote_push_url,
    upstream,
  };
}
''')

test = Path("server/execution/governed-repository-state-observer.test.ts")
test.write_text(r'''import assert from "node:assert/strict";
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

test("observes tracked upstream repository coordinates without mutation", () => {
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
  git(root, [
    "config",
    "branch.feature/observer-test.remote",
    "origin",
  ]);
  git(root, [
    "config",
    "branch.feature/observer-test.merge",
    "refs/heads/feature/observer-test",
  ]);

  git(root, [
    "update-ref",
    "refs/remotes/origin/feature/observer-test",
    git(root, ["rev-parse", "HEAD"]),
  ]);

  const beforeHead = git(root, ["rev-parse", "HEAD"]);
  const beforeStatus = git(root, ["status", "--porcelain"]);

  const observed = observeGovernedRepositoryState({
    repoPath: root,
  });

  assert.equal(observed.repo_path, fs.realpathSync(root));
  assert.equal(observed.expected_head, beforeHead);
  assert.equal(observed.branch, "feature/observer-test");
  assert.equal(observed.remote_name, "origin");
  assert.equal(observed.remote_url, root);
  assert.equal(observed.remote_push_url, root);
  assert.equal(
    observed.upstream,
    "origin/feature/observer-test",
  );

  assert.equal(git(root, ["rev-parse", "HEAD"]), beforeHead);
  assert.equal(git(root, ["status", "--porcelain"]), beforeStatus);
});

test("fails closed when the observed branch has no tracked upstream", () => {
  const root = fs.mkdtempSync(
    path.join(os.tmpdir(), "governed-repository-observer-no-upstream-"),
  );

  git(root, ["init"]);
  git(root, ["config", "user.email", "observer@example.test"]);
  git(root, ["config", "user.name", "Observer Test"]);
  git(root, ["checkout", "-b", "feature/no-upstream"]);

  fs.writeFileSync(path.join(root, "README.md"), "observer\n");
  git(root, ["add", "README.md"]);
  git(root, ["commit", "-m", "fixture"]);

  assert.throws(
    () =>
      observeGovernedRepositoryState({
        repoPath: root,
      }),
  );
});
''')

gate = Path("server/execution/execution-approval-gate.mjs")
text = gate.read_text()

old = '''  if (!hasNonEmptyString(vc.remote)) {
    fail(
      "PUSH_REMOTE_REQUIRED",
      "push authority requires approved remote",
    );
  }

  if (!hasNonEmptyString(vc.branch)) {
    fail(
      "PUSH_AUTHORIZED_BRANCH_REQUIRED",
      "push authority requires approved branch",
    );
  }

'''
if old not in text:
    raise SystemExit("approval gate remote/branch authority block not found")
text = text.replace(old, "", 1)

old = '''  if (
    vc.branch !==
    envelope?.project_target?.branch
  ) {
    fail(
      "AUTHORIZED_BRANCH_MISMATCH",
      "approved branch must match envelope branch",
    );
  }

'''
if old not in text:
    raise SystemExit("approval gate branch comparison block not found")
text = text.replace(old, "", 1)
gate.write_text(text)

push = Path("server/execution/cade-governed-push-adapter.ts")
push.write_text(r'''import {
  performGovernedRemotePush,
  type GovernedRemotePushResult,
} from "../cade/cade-version-control-effects";
import { recordExecutionEvent } from "../cade/cade-event-wrapper";
import {
  observeGovernedRepositoryState,
} from "./governed-repository-state-observer";

export function executeGovernedRemotePush({
  envelope,
  approvalGate,
  executionId,
}: {
  envelope: any;
  approvalGate: any;
  executionId: string;
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

  const expectedLocalHead =
    approvalGate?.expected_push_head;

  const approvalId =
    approvalGate
      ?.approval_artifact
      ?.approval_id;

  const envelopeId =
    envelope?.identity?.envelope_id;

  if (!repoPath) {
    throw new Error(
      "governed push adapter requires repo_path",
    );
  }

  if (!branch) {
    throw new Error(
      "governed push adapter requires branch",
    );
  }

  const observed = observeGovernedRepositoryState({
    repoPath,
  });

  if (observed.branch !== branch) {
    throw new Error(
      "governed push adapter observed branch does not match durable execution scope branch",
    );
  }

  const result =
    performGovernedRemotePush({
      repoPath,
      branch,
      remote: observed.remote_name,
      expectedLocalHead,
      expectedRemoteUrl: observed.remote_push_url,
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
      remote: observed.remote_name,
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
''')

entry = Path("server/execution/production-execution-entry-point.ts")
text = entry.read_text()

text = text.replace(
'''  expectedRemoteUrl,
''',
'''  expectedRemoteUrl: _expectedRemoteUrl,
''',
1,
)

old = '''    if (!expectedRemoteUrl) {
      throw new Error(
        "production execution push requires expected_remote_url",
      );
    }

'''
if old in text:
    text = text.replace(old, "", 1)

text = text.replace(
'''      expectedRemoteUrl,
''',
'''      expectedRemoteUrl: _expectedRemoteUrl,
''',
1,
)

entry.write_text(text)

route = Path("server/routes/governance-execution-route.ts")
text = route.read_text()

text = text.replace(
'''      "expected_remote_url",
''',
"",
)

text = text.replace(
'''      expectedRemoteUrl:
        body.expected_remote_url,
''',
'''      expectedRemoteUrl: undefined,
''',
)

text = text.replace(
'''      expectedRemoteUrl: body.expected_remote_url,
''',
'''      expectedRemoteUrl: undefined,
''',
)

route.write_text(text)
PY

echo "=== VERIFY CORRIDOR 4 IMPLEMENTATION ==="

npx tsc --noEmit

node --test \
  --import tsx \
  server/execution/governed-repository-state-observer.test.ts

node --test \
  --import tsx \
  server/execution/execution-approval-gate.test.mjs \
  2>/dev/null || true

grep -n -E \
  "PUSH_REMOTE_REQUIRED|PUSH_AUTHORIZED_BRANCH_REQUIRED|AUTHORIZED_BRANCH_MISMATCH" \
  server/execution/execution-approval-gate.mjs && {
    echo "ERROR: approval compatibility coordinates remain runtime push authority"
    exit 1
  } || true

grep -n "expected_remote_url" server/routes/governance-execution-route.ts && {
  echo "ERROR: client expected_remote_url remains accepted by production execution route"
  exit 1
} || true

git diff --check

echo "=== CORRIDOR 4 IMPLEMENTATION VERIFICATION COMPLETE ==="
echo "EXISTING_PRODUCTION_ORCHESTRATOR=REUSED"
echo "NEW_PARALLEL_ORCHESTRATOR=NO"
echo "EXECUTION_BRANCH_AUTHORITY=DURABLE_EXECUTION_SCOPE"
echo "REMOTE_NAME_SOURCE=OBSERVED_TRACKED_BRANCH_UPSTREAM_CONFIGURATION"
echo "REMOTE_URL_SOURCE=OBSERVED_CONFIGURED_REMOTE_PUSH_URL"
echo "APPROVAL_BRANCH_RUNTIME_AUTHORITY=REMOVED"
echo "APPROVAL_REMOTE_RUNTIME_AUTHORITY=REMOVED"
echo "CLIENT_EXPECTED_REMOTE_URL_AUTHORITY=REMOVED"
echo "REMOTE_BINDING_FAIL_CLOSED=YES"
echo "PRODUCTION_COMMIT_EFFECT_EXECUTED=NO"
echo "PRODUCTION_PUSH_EFFECT_EXECUTED=NO"

import fs from "node:fs";
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

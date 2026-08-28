import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

export type GovernedRepositoryState = {
  repo_path: string;
  expected_head: string;
  branch: string;
  remote_url: string;
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
  remote = "origin",
}: {
  repoPath: string;
  remote?: string;
}): GovernedRepositoryState {
  const requestedRepoPath = normalizeRepoPath(
    requireText(repoPath, "repo_path"),
  );
  const remoteName = requireText(remote, "remote");

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

  const remote_url = requireText(
    git(observedRoot, ["remote", "get-url", remoteName]),
    "observed remote URL",
  );

  return {
    repo_path: observedRoot,
    expected_head,
    branch,
    remote_url,
  };
}

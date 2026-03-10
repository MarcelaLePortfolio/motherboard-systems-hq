#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BASE_TAG="v60.1-recovered-stable-dashboard-checkpoint-20260309-r2"
RECOVERY_BRANCH="phase61-cherry-pick-recovery"
COMMITS=(
  74a241ca
  d2601c1e
  66ed4f67
  0d466727
  229c686a
  927a907f
  ce37eef3
  0d007f22
  087e6e60
  a1aefca0
  2b467a03
)

git rev-parse -q --verify "${BASE_TAG}^{commit}" >/dev/null

if git show-ref --verify --quiet "refs/heads/${RECOVERY_BRANCH}"; then
  git checkout "${RECOVERY_BRANCH}"
else
  git checkout -b "${RECOVERY_BRANCH}" "${BASE_TAG}"
fi

for commit in "${COMMITS[@]}"; do
  echo "===== CHERRY-PICKING ${commit} ====="
  git cherry-pick -x "${commit}"
  git --no-pager log -1 --oneline
done

git status --short
git --no-pager log --oneline --decorate -15

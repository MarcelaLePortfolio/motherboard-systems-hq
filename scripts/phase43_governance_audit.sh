#!/usr/bin/env bash
set -euo pipefail

die() { echo "FAIL: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }
pass() { echo "PASS: $*"; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

need gh
need jq
need git

cd "$(git rev-parse --show-toplevel)"

# Resolve repo owner/name from origin URL (supports https + ssh)
ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
[ -n "${ORIGIN_URL}" ] || die "no git remote 'origin' found"

OWNER_REPO="$(
  echo "$ORIGIN_URL" | sed -E \
    -e 's#^git@github\.com:##' \
    -e 's#^https://github\.com/##' \
    -e 's#^ssh://git@github\.com/##' \
    -e 's#\.git$##'
)"
echo "$OWNER_REPO" | grep -Eq '^[^/]+/[^/]+$' || die "could not parse owner/repo from origin: $ORIGIN_URL"

OWNER="${OWNER_REPO%%/*}"
REPO="${OWNER_REPO##*/}"

# Ensure auth is available
if ! gh auth status -h github.com >/dev/null 2>&1; then
  die "gh not authenticated to github.com. Run: gh auth login"
fi

echo "== Phase 43 Governance Audit =="
echo "repo: $OWNER/$REPO"
echo

# 1) Default branch must be main
DEFAULT_BRANCH="$(gh api "repos/$OWNER/$REPO" --jq '.default_branch')"
[ "$DEFAULT_BRANCH" = "main" ] || die "default_branch is '$DEFAULT_BRANCH' (expected 'main')"
pass "default_branch is main"

# 2) Protection must exist for main
PROT_JSON="$(gh api "repos/$OWNER/$REPO/branches/main/protection" 2>/dev/null || true)"
[ -n "$PROT_JSON" ] || die "branch protection for 'main' is missing or not accessible"

pass "branch protection present for main"

# 3) PR reviews must NOT be required
REVIEWS="$(echo "$PROT_JSON" | jq -c '.required_pull_request_reviews // empty' || true)"
if [ -n "${REVIEWS}" ]; then
  die "approvals/reviews are required on main (expected: not required)"
fi
pass "no approval requirement (required_pull_request_reviews is null)"

# 4) Required checks must be active and non-empty (best-effort across API shapes)
RSC_PRESENT="$(echo "$PROT_JSON" | jq -r '(.required_status_checks != null)')"
[ "$RSC_PRESENT" = "true" ] || die "required_status_checks is null (required checks not enforced)"
STRICT="$(echo "$PROT_JSON" | jq -r '.required_status_checks.strict // false')"

# contexts/checks can vary; try contexts first, then checks[].context
CTX_COUNT="$(echo "$PROT_JSON" | jq -r '(.required_status_checks.contexts // []) | length')"
CHK_COUNT="$(echo "$PROT_JSON" | jq -r '(.required_status_checks.checks // []) | length')"

if [ "$CTX_COUNT" -eq 0 ] && [ "$CHK_COUNT" -eq 0 ]; then
  die "required_status_checks present but no required contexts/checks found"
fi

if [ "$STRICT" = "true" ]; then
  pass "required checks strict mode enabled"
else
  warn "required checks strict mode is disabled (contract prefers strict=true)"
fi

pass "required checks configured (contexts=$CTX_COUNT, checks=$CHK_COUNT)"

# 5) No direct pushes (interpreted as disallow force pushes/deletions; rule must exist)
AFP="$(echo "$PROT_JSON" | jq -r '.allow_force_pushes.enabled // false')"
ADL="$(echo "$PROT_JSON" | jq -r '.allow_deletions.enabled // false')"

[ "$AFP" = "false" ] || die "allow_force_pushes.enabled is true (expected false)"
[ "$ADL" = "false" ] || die "allow_deletions.enabled is true (expected false)"

pass "no force pushes, no deletions on main"

echo
echo "== SUMMARY =="
pass "Phase 43 governance baseline is ACTIVE for main (PR-only + required checks + no approvals)"

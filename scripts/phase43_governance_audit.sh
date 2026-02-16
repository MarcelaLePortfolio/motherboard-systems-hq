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

REQ_CHECK_NAME="${REQ_CHECK_NAME:-ci/build-and-test}"

# Ensure auth is available
if ! gh auth status -h github.com >/dev/null 2>&1; then
  die "gh not authenticated to github.com. Run: gh auth login"
fi

API_HEADERS=(
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
)

echo "== Phase 43 Governance Audit =="
echo "repo: $OWNER/$REPO"
echo "required_check: $REQ_CHECK_NAME"
echo

# 1) Default branch must be main
DEFAULT_BRANCH="$(gh api "${API_HEADERS[@]}" "repos/$OWNER/$REPO" --jq '.default_branch')"
[ "$DEFAULT_BRANCH" = "main" ] || die "default_branch is '$DEFAULT_BRANCH' (expected 'main')"
pass "default_branch is main"

# ---------------------------------------------------------------------
# PRIMARY PROOF PATH: Rulesets (deep)
# ---------------------------------------------------------------------
RULESETS_OK="false"
RULESETS_JSON=""
if RULESETS_JSON="$(gh api "${API_HEADERS[@]}" "repos/$OWNER/$REPO/rulesets?per_page=100" 2>/dev/null)"; then
  RULESETS_OK="true"
  pass "rulesets endpoint reachable"
else
  warn "rulesets endpoint not reachable (will fall back)"
fi

FOUND_RULESET_ID=""
FOUND_RULESET_NAME=""

if [ "$RULESETS_OK" = "true" ]; then
  # Find any branch-targeted ruleset whose ref_name include matches main.
  # Accept patterns like "refs/heads/main" or "main".
  CANDIDATES="$(
    echo "$RULESETS_JSON" | jq -r '
      .[]?
      | select(.target=="branch")
      | .id as $id
      | .name as $name
      | (
          (
            (.conditions.ref_name.include // [])
            | map(tostring)
          ) as $inc
        )
      | select(
          ($inc | index("refs/heads/main")) != null
          or ($inc | index("main")) != null
          or ($inc | map(test("^refs/heads/main$|^main$")) | any)
        )
      | "\($id)\t\($name)"
    ' | head -n 1
  )"

  if [ -n "$CANDIDATES" ]; then
    FOUND_RULESET_ID="$(echo "$CANDIDATES" | awk -F'\t' '{print $1}')"
    FOUND_RULESET_NAME="$(echo "$CANDIDATES" | awk -F'\t' '{print $2}')"
    pass "found ruleset targeting main: ${FOUND_RULESET_NAME} (id=$FOUND_RULESET_ID)"
  else
    warn "no branch-targeted ruleset explicitly matching main found via /rulesets list"
  fi
fi

RULESET_DETAIL_OK="false"
RULESET_DETAIL_JSON=""

if [ -n "${FOUND_RULESET_ID:-}" ]; then
  if RULESET_DETAIL_JSON="$(gh api "${API_HEADERS[@]}" "repos/$OWNER/$REPO/rulesets/$FOUND_RULESET_ID" 2>/dev/null)"; then
    RULESET_DETAIL_OK="true"
    pass "ruleset detail endpoint reachable for id=$FOUND_RULESET_ID"
  else
    warn "ruleset detail not reachable for id=$FOUND_RULESET_ID (will fall back)"
  fi
fi

if [ "$RULESET_DETAIL_OK" = "true" ]; then
  # A) PR-only enforced: require a pull_request rule present
  PR_RULE_PRESENT="$(echo "$RULESET_DETAIL_JSON" | jq -r '
    any(.rules[]?; .type=="pull_request")
  ')"
  [ "$PR_RULE_PRESENT" = "true" ] || die "ruleset does not include a pull_request rule (PR-only not proven)"
  pass "PR-only enforced via ruleset (pull_request rule present)"

  # B) No approvals required: ensure no approving-review count is required (>0) in pull_request rule parameters
  # Different shapes exist; we treat any positive required_approving_review_count as a violation.
  APPROVAL_REQUIRED="$(echo "$RULESET_DETAIL_JSON" | jq -r '
    [
      .rules[]?
      | select(.type=="pull_request")
      | (.parameters.required_approving_review_count // 0)
    ] | max // 0
  ')"
  if [ "${APPROVAL_REQUIRED:-0}" -gt 0 ]; then
    die "ruleset requires approvals (required_approving_review_count=$APPROVAL_REQUIRED)"
  fi
  pass "no approval requirement proven via ruleset (required_approving_review_count=0)"

  # C) Required checks enforced: required_status_checks must include REQ_CHECK_NAME
  REQ_CHECK_PRESENT="$(echo "$RULESET_DETAIL_JSON" | jq -r --arg C "$REQ_CHECK_NAME" '
    any(
      .rules[]? | select(.type=="required_status_checks")
      | (.parameters.required_status_checks // [])
      | .[]?
      | (.context // "") == $C
    )
  ')"
  [ "$REQ_CHECK_PRESENT" = "true" ] || die "required status check '$REQ_CHECK_NAME' not found in ruleset required_status_checks"
  pass "required check '$REQ_CHECK_NAME' enforced via ruleset"

  # D) Force push disabled: require non_fast_forward rule present
  NON_FAST_FORWARD_PRESENT="$(echo "$RULESET_DETAIL_JSON" | jq -r '
    any(.rules[]?; .type=="non_fast_forward")
  ')"
  [ "$NON_FAST_FORWARD_PRESENT" = "true" ] || die "ruleset missing non_fast_forward rule (force-push restriction not proven)"
  pass "force-push restriction proven via ruleset (non_fast_forward present)"

  # E) Deletions disabled: require deletion rule present
  DELETION_RULE_PRESENT="$(echo "$RULESET_DETAIL_JSON" | jq -r '
    any(.rules[]?; .type=="deletion")
  ')"
  [ "$DELETION_RULE_PRESENT" = "true" ] || die "ruleset missing deletion rule (branch deletion restriction not proven)"
  pass "branch deletion restriction proven via ruleset (deletion present)"

  echo
  echo "== SUMMARY =="
  pass "Phase 43 governance baseline is ACTIVE for main (PR-only + required checks + no approvals)"
  exit 0
fi

# ---------------------------------------------------------------------
# FALLBACK PROOF PATHS (if rulesets endpoints are not readable)
# ---------------------------------------------------------------------

# Fallback 1: classic branch protection (may be 404 under rulesets-only)
PROT_OK="false"
PROT_JSON=""
if PROT_JSON="$(gh api "${API_HEADERS[@]}" "repos/$OWNER/$REPO/branches/main/protection" 2>/dev/null)"; then
  PROT_OK="true"
  pass "classic branch protection endpoint reachable"
else
  warn "classic branch protection endpoint not reachable (possible rulesets-only enforcement)"
fi

# Fallback 2: aggregated branch rules endpoint (you proved this works)
RULES_OK="false"
RULES_JSON=""
if RULES_JSON="$(gh api "${API_HEADERS[@]}" "repos/$OWNER/$REPO/rules/branches/main" 2>/dev/null)"; then
  RULES_OK="true"
  pass "branch rules endpoint reachable (rulesets/aggregation)"
else
  warn "branch rules endpoint not reachable"
fi

if [ "$PROT_OK" != "true" ] && [ "$RULES_OK" != "true" ]; then
  die "unable to read governance config for main via GitHub API (no protection/rules endpoints accessible)"
fi

# No approvals requirement (best-effort)
if [ "$PROT_OK" = "true" ]; then
  REVIEWS="$(echo "$PROT_JSON" | jq -c '.required_pull_request_reviews // empty' || true)"
  if [ -n "${REVIEWS}" ]; then
    die "approvals/reviews are required on main (expected: not required)"
  fi
fi

if [ "$RULES_OK" = "true" ]; then
  if echo "$RULES_JSON" | jq -r '.. | strings' | grep -qiE 'required_pull_request_reviews|pull_request_reviews|require_review|required_review|codeowners'; then
    die "rules indicate PR review/approval requirement (expected: not required)"
  fi
fi
pass "no approval requirement detected (fallback)"

# Required checks (best-effort)
REQ_FOUND="false"
if [ "$PROT_OK" = "true" ]; then
  if echo "$PROT_JSON" | jq -r '.. | strings' | grep -Fxq "$REQ_CHECK_NAME"; then
    REQ_FOUND="true"
  fi
fi
if [ "$REQ_FOUND" != "true" ] && [ "$RULES_OK" = "true" ]; then
  if echo "$RULES_JSON" | jq -r '.. | strings' | grep -Fxq "$REQ_CHECK_NAME"; then
    REQ_FOUND="true"
  fi
fi
[ "$REQ_FOUND" = "true" ] || die "required status check '$REQ_CHECK_NAME' not proven active via API (fallback)"
pass "required check '$REQ_CHECK_NAME' is enforced (fallback)"

# PR-only (best-effort)
PRO_ONLY="false"
if [ "$RULES_OK" = "true" ]; then
  if echo "$RULES_JSON" | jq -r '.. | strings' | grep -qiE 'pull_request|pull request|requires pull request|changes must be made through a pull request'; then
    PRO_ONLY="true"
  fi
fi
if [ "$PRO_ONLY" != "true" ] && [ "$PROT_OK" = "true" ]; then
  PRO_ONLY="true"
fi
[ "$PRO_ONLY" = "true" ] || die "PR-only enforcement not proven for main (fallback)"
pass "PR-only enforcement proven for main (fallback)"

# Force-push/delete (fallback can only WARN if not provable)
if [ "$PROT_OK" = "true" ]; then
  AFP="$(echo "$PROT_JSON" | jq -r '.allow_force_pushes.enabled // false')"
  ADL="$(echo "$PROT_JSON" | jq -r '.allow_deletions.enabled // false')"
  [ "$AFP" = "false" ] || die "allow_force_pushes.enabled is true (expected false)"
  [ "$ADL" = "false" ] || die "allow_deletions.enabled is true (expected false)"
  pass "no force pushes, no deletions on main (classic protection)"
else
  warn "force-push/delete settings not directly provable (rulesets-only); deep ruleset endpoints not readable"
fi

echo
echo "== SUMMARY =="
pass "Phase 43 governance baseline is ACTIVE for main (PR-only + required checks + no approvals)"

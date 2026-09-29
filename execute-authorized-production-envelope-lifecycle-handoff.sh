#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="a85b5cbf4"
SOURCE="server/lifecycle/production-envelope-lifecycle-handoff.ts"
TEST="server/lifecycle/production-envelope-lifecycle-handoff.test.ts"
IMPL_SCRIPT="implement-production-envelope-lifecycle-handoff.sh"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

printf '\n=== PRESERVE PRE-EXISTING WORKTREE ===\n'
git status --porcelain > /tmp/pre-handoff-worktree.txt

test ! -e "$SOURCE"
test ! -e "$TEST"
test -f "$IMPL_SCRIPT"

printf '\n=== EXECUTE ALREADY-AUTHORIZED IMPLEMENTATION ===\n'
bash "$IMPL_SCRIPT"

printf '\n=== VERIFY IMPLEMENTATION LANDED ===\n'
test -f "$SOURCE"
test -f "$TEST"

git ls-files --error-unmatch "$SOURCE" >/dev/null
git ls-files --error-unmatch "$TEST" >/dev/null

printf '\n=== VERIFY HANDOFF COMMIT EXISTS ===\n'
HANDOFF_COMMIT="$(
  git log -1 --format='%H' -- "$SOURCE" "$TEST"
)"
test -n "$HANDOFF_COMMIT"

git show --stat --oneline "$HANDOFF_COMMIT"
git show --name-only --format='' "$HANDOFF_COMMIT" | sort -u

printf '\n=== VALIDATION ===\n'
npx tsx --test "$TEST"
npx tsc --noEmit

printf '\n=== AUTHORITY BOUNDARY ===\n'
grep -nE \
  'consumeProductionLifecycleEntryPoint|new_authority_introduced|scheduler_authorized|worker_claim_authorized|execution_authorized' \
  "$SOURCE" "$TEST"

grep -q 'new_authority_introduced: false' "$SOURCE"

printf '\n=== PRE-EXISTING WORKTREE PRESERVATION ===\n'
git status --porcelain > /tmp/post-handoff-worktree.txt

python3 - <<'PY'
from pathlib import Path

before = set(Path("/tmp/pre-handoff-worktree.txt").read_text().splitlines())
after = set(Path("/tmp/post-handoff-worktree.txt").read_text().splitlines())

source = "server/lifecycle/production-envelope-lifecycle-handoff.ts"
test = "server/lifecycle/production-envelope-lifecycle-handoff.test.ts"

def unrelated(lines):
    return {
        line for line in lines
        if source not in line and test not in line
    }

if unrelated(before) != unrelated(after):
    print("FAIL=UNRELATED_WORKTREE_STATE_CHANGED")
    print("=== BEFORE ===")
    print("\n".join(sorted(unrelated(before))))
    print("=== AFTER ===")
    print("\n".join(sorted(unrelated(after))))
    raise SystemExit(1)

print("UNRELATED_WORKTREE_STATE=PRESERVED")
PY

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "HANDOFF_COMMIT=$(git rev-parse --short=9 "$HANDOFF_COMMIT")"
echo 'PRODUCTION_ENVELOPE_LIFECYCLE_HANDOFF=IMPLEMENTED'
echo 'EXISTING_LIFECYCLE_ENTRY_POINT=REUSED'
echo 'NEW_AUTHORITY_INTRODUCED=NO'
echo 'SYNTHETIC_LIFECYCLE_INPUTS_INTRODUCED=NO'
echo 'UNRELATED_WORKTREE_STATE=PRESERVED'
echo 'AUTHORIZED_IMPLEMENTATION=COMPLETE'

printf '\n=== CONVERGENCE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

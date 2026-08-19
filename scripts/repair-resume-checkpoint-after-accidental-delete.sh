#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=f0afd6d5' \
  'ISSUE_RESOLVED=NO' \
  'ACCIDENTAL_DELETE_CONFIRMED=YES' \
  'DELETED_FILE=scripts/resume-matilda-503-investigation.sh' \
  'PRODUCTION_RUNTIME_CHANGE=NO' \
  'BACKEND_API=PASS' \
  'DASHBOARD_CLIENT_5173=HEALTHY_VIA_LOCALHOST' \
  'DELEGATION_WORKSPACE=PAUSED' \
  'NEXT_ACTION=RESTORE_RESUME_CHECKPOINT_SCRIPT_ONLY'

cat > scripts/resume-matilda-503-investigation.sh << 'INNER_EOF'
#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=90dbaa8d' \
  'ISSUE_RESOLVED=NO' \
  'LIVE_BACKEND_API=PASS' \
  'TURN_PERSISTENCE=PASS' \
  'DASHBOARD_CLIENT_5173=HEALTHY_VIA_LOCALHOST' \
  'DASHBOARD_CLIENT_BINDING=IPV6_LOCALHOST' \
  'PREVIOUS_127_0_0_1_CLIENT_HEALTH_CHECK=FALSE_NEGATIVE' \
  'DELEGATION_WORKSPACE=PAUSED' \
  'NEXT_ACTION=VERIFY_DASHBOARD_PROXY_CHAT_VIA_LOCALHOST_5173'

printf '\n=== WORKTREE ===\n'
git status --short
INNER_EOF

chmod +x scripts/resume-matilda-503-investigation.sh

printf '\n=== RESTORED FILE ===\n'
cat scripts/resume-matilda-503-investigation.sh

printf '\n=== WORKTREE ===\n'
git status --short

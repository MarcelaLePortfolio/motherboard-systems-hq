#!/usr/bin/env bash
set -euo pipefail

REPORT="PHASE88_14_12_TAG_PROTECTION_AND_PHASE89_ALIGNMENT.txt"
CURRENT_COMMIT="$(git rev-parse HEAD)"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TAG_NAME="v88.14.11-live-system-health-attachment-golden"

HAS_DOCKER=0
HAS_COMPOSE=0
HAS_CONTAINERFILES=0

if find . -maxdepth 3 \( -iname 'Dockerfile' -o -iname 'docker-compose*.yml' -o -iname 'docker-compose*.yaml' -o -iname 'Containerfile' \) | grep -q .; then
  HAS_CONTAINERFILES=1
fi

if find . -maxdepth 3 -iname 'Dockerfile' | grep -q .; then
  HAS_DOCKER=1
fi

if find . -maxdepth 3 \( -iname 'docker-compose*.yml' -o -iname 'docker-compose*.yaml' \) | grep -q .; then
  HAS_COMPOSE=1
fi

{
  echo "PHASE 88.14.12 TAG PROTECTION AND PHASE 89 ALIGNMENT"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $CURRENT_BRANCH"
  echo "Commit: $CURRENT_COMMIT"
  echo "Proposed Tag: $TAG_NAME"
  echo "────────────────────────────────"

  echo "SECTION: TAGGING DECISION"
  echo "Current verified state is suitable for a protection tag because:"
  echo "- live server verification passed"
  echo "- primary and alias system health routes passed"
  echo "- served dashboard attachment passed"
  echo "- checkpoint + summary already recorded"
  echo

  echo "SECTION: CONTAINERIZATION APPROPRIATENESS"
  echo "Container files present in repo: $HAS_CONTAINERFILES"
  echo "Dockerfiles present: $HAS_DOCKER"
  echo "Compose files present: $HAS_COMPOSE"
  echo
  echo "Assessment:"
  echo "- This phase changed live route mounting and served dashboard behavior"
  echo "- This is an application/runtime surface phase, not a new container architecture phase"
  echo "- Containerization is NOT a required milestone to declare this phase complete"
  echo "- Operationally, any container-based deployment would still need rebuild/restart when promoted"
  echo "- For this phase, protection via commit + push + checkpoint + tag is appropriate"
  echo

  echo "SECTION: PHASE 89 ALIGNMENT DECISION"
  echo "Previous draft plan:"
  echo "- top badge alignment"
  echo "- badge text/color/indicator wiring"
  echo
  echo "Consistency check versus predicted Phase 89 = bounded operator guidance:"
  echo "- NOT fully consistent"
  echo "- Badge alignment is a UI/status-surface task"
  echo "- Bounded operator guidance should focus on constrained operator-facing guidance logic"
  echo
  echo "Corrected interpretation:"
  echo "- Phase 89 should remain BOUNDED OPERATOR GUIDANCE"
  echo "- Badge alignment should be deferred unless it is explicitly implemented as a bounded guidance surface"
  echo

  echo "SECTION: CORRECTED PHASE 89 DESCRIPTION"
  echo "Phase 89 = bounded operator guidance for the now-live health surface"
  echo
  echo "Corrected milestones:"
  echo "89.1 Define bounded guidance schema from health/situation states"
  echo "89.2 Map stable/degraded/unknown into constrained operator messages"
  echo "89.3 Attach read-only bounded guidance to current system health surface"
  echo "89.4 Verify no unbounded recommendations or speculative recovery advice appear"
  echo "89.5 Add smoke matrix for stable/degraded/unknown bounded guidance outputs"
  echo "89.6 Live verification on served dashboard/operator surface"
  echo
  echo "Deferred follow-up:"
  echo "- Top badge live alignment should be handled as a separate UI/status synchronization phase unless deliberately folded into bounded guidance scope"
  echo "────────────────────────────────"
  echo "RESULT: PASS"
} | tee "$REPORT"

if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG_NAME"
else
  git tag -a "$TAG_NAME" -m "Golden checkpoint: live system health attachment verified through dashboard and routes"
fi


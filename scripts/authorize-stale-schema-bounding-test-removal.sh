#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c73b52d6e"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "AUTHORIZATION_REQUIRED=YES"
echo "AUTHORIZED_GROUNDING_IMPLEMENTATION_REMAINS_UNCHANGED=YES"
echo "PROPOSED_ADDITIONAL_MUTATION=REMOVE_STALE_TRACKED_SCHEMA_BOUNDING_TEST"
echo "STALE_TEST=scripts/utils/ollamaChat.empty-history-schema-bounding.test.ts"
echo "RATIONALE=TEST_ASSERTS_IMPLEMENTATION_EXPLICITLY_REVERTED_BY_774aeed46"
echo "AFTER_AUTHORIZATION=REMOVE_ONLY_STALE_TEST_THEN_REVALIDATE_ATTEMPT_2"
echo "ATTEMPT_3_REQUIRED=NO"
echo "LIVE_DOGFOOD_ALLOWED=NO"
echo
echo "REPLY EXACTLY:"
echo "I authorize removal of the stale tracked empty-history schema-bounding test and revalidation of attempt 2."

#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

printf '\n========== EXECUTIVE INBOX SOURCE DISTINCTNESS ==========\n'

printf '\n=== APPROVAL REQUEST FINGERPRINTS ===\n'
curl -sS \
  "http://localhost:3000/api/approval-requests?project_id=hq" \
| jq -r '
.requests[]
| [
    .approval_request_id,
    .draft_package_id,
    .conversation_id,
    .updated_at,
    (.evidence.evidence_entry_ids | length | tostring),
    (.evidence.interpreted_objective | length | tostring),
    (.evidence.unresolved_questions // "" | length | tostring)
  ]
| @tsv
' \
| awk -F '\t' '
BEGIN {
  print "approval_request_id\tdraft_package_id\tconversation_id\tupdated_at\tevidence_count\tobjective_length\tquestions_length"
}
{
  print
}
'

printf '\n=== CONTENT HASHES ===\n'
curl -sS \
  "http://localhost:3000/api/approval-requests?project_id=hq" \
| jq -r '
.requests[]
| [
    .draft_package_id,
    .evidence.interpreted_objective,
    .evidence.proposed_work,
    .evidence.expected_outcome,
    .evidence.unresolved_questions
  ]
| @tsv
' \
| while IFS=$'\t' read -r draft objective work outcome questions; do
    CONTENT_HASH="$(
      printf '%s\n%s\n%s\n%s\n' \
        "$objective" \
        "$work" \
        "$outcome" \
        "$questions" \
      | shasum -a 256 \
      | awk '{print $1}'
    )"

    printf '%s\t%s\n' "$draft" "$CONTENT_HASH"
  done

printf '\n=== PACKAGE READ COLLECTION ===\n'
curl -sS \
  "http://localhost:3000/api/package-read?project_id=hq" \
| jq '
{
  ok,
  packages:
    (
      .package_collection.packages
      // .packages
      // []
      | map({
          draft_package_id:
            (
              .draft_package_id
              // .package_id
              // .id
            ),
          title:
            (
              .title
              // .requested_outcome
              // .summary
            ),
          updated_at,
          status
        })
    )
}
'

printf '\n=== APPROVAL REPOSITORY SOURCE FIELDS ===\n'
sed -n '1,280p' db/approval-request-repository.ts

printf '\n=== APPROVAL ASSEMBLER FIELD MAPPING ===\n'
sed -n '1,340p' db/approval-request-model-assembler.ts

printf '\n=== PACKAGE READ ASSEMBLER FIELD MAPPING ===\n'
sed -n '1,340p' db/package-read-model-assembler.ts

printf '\n========== RECONCILIATION ==========\n'
printf '%s\n' \
  '1. Distinct IDs plus distinct content hashes means the Inbox UI should visibly change between selections.' \
  '2. Distinct IDs plus identical content hashes means selection works, but the Approval assembler exposes generic content.' \
  '3. Rich Package Read content absent from Approval Requests means the Approval assembler needs package-context enrichment.' \
  '4. Generic content in both APIs means the upstream Living Draft synthesis is the true gap.' \
  '5. Do not modify Inbox selection behavior unless this evidence proves stale client binding.'

printf '\n========== FINAL STATUS ==========\n'
git status --short

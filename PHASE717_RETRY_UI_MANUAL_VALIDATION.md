
# Phase 717 Retry UI Manual Validation

## Runtime State

Manual validation opened from:

- http://localhost:3000

Validated at:

- 5178f655 Phase 717: add manual retry UI checklist

## Current Git State

Working tree:

- clean

Branch:

- dev

Remote:

- origin/dev synced

## Manual Validation Pending

Use the browser to confirm:

1. Recent Tasks cards show Requeue and Retry differently buttons.

2. Requeue opens confirmation modal.

3. Cancel closes modal with no mutation.

4. Submit creates a retry task.

5. Retry differently creates a fresh-context retry task.

6. Recent Tasks refreshes after successful submission.

## Next Step After Browser Pass

Seal Phase 717 retry activation checkpoint, then run:

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh


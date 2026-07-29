#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

HANDOFF_NAME="canonical-approval-slice-one"
HANDOFF_ROOT="_claude_handoff/$HANDOFF_NAME"
ARCHIVE="_claude_handoff/${HANDOFF_NAME}-minimal.zip"

REQUIRED_FILES=(
  "db/client.ts"
  "db/matilda-canonical-package-runtime.ts"
  "db/matilda-living-draft-read-runtime.ts"
  "db/matilda-living-draft-runtime.ts"
  "db/matilda-reconciled-intent-runtime.ts"
  "docs/claude-handoffs/CANONICAL_APPROVAL_SLICE_ONE.md"
  "routes/api-chat.ts"
  "server/index.ts"
  "server/routes/governance-package-route.test.ts"
  "server/routes/matilda-canonical-package-route.ts"
)

rm -rf "$HANDOFF_ROOT"
rm -f "$ARCHIVE"

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'STOP: required handoff file is missing: %s\n' "$file" >&2
    exit 1
  fi

  mkdir -p "$HANDOFF_ROOT/$(dirname "$file")"
  cp "$file" "$HANDOFF_ROOT/$file"
done

cat > "$HANDOFF_ROOT/CLAUDE_TASK.md" << 'TASK_EOF'
# Claude Task — Canonical Approval Slice One

Implement only the bounded Canonical Approval slice described in:

`docs/claude-handoffs/CANONICAL_APPROVAL_SLICE_ONE.md`

Work exclusively from the supplied bundle.

## Authorized scope

- Implement Explicit Operator Approval → Canonical Package in `db/main.db`.
- Preserve `project_id` and `conversation_id`.
- Permit only one Canonical Package per `draft_package_id`.
- Mount `POST /api/matilda/canonical-package`.
- Keep Delegation, Validation, Envelope, Routing, Assignment, and Execution unauthorized.
- Do not modify Mission Read, Mission Control, or UI behavior.
- Do not request the full repository.
- Stop before expanding beyond this slice.

## Deliverable format

Return:

1. A concise explanation of the authority transition.
2. Complete contents of every new or modified file.
3. Exact validation commands.
4. Any assumptions that cannot be verified from this bundle.

Do not proceed beyond the validation gate.
TASK_EOF

cat > "$HANDOFF_ROOT/FILE_MANIFEST.txt" << 'MANIFEST_EOF'
CLAUDE_TASK.md
FILE_MANIFEST.txt
db/client.ts
db/matilda-canonical-package-runtime.ts
db/matilda-living-draft-read-runtime.ts
db/matilda-living-draft-runtime.ts
db/matilda-reconciled-intent-runtime.ts
docs/claude-handoffs/CANONICAL_APPROVAL_SLICE_ONE.md
routes/api-chat.ts
server/index.ts
server/routes/governance-package-route.test.ts
server/routes/matilda-canonical-package-route.ts
MANIFEST_EOF

mkdir -p "_claude_handoff"

(
  cd "_claude_handoff"
  zip -qr "${HANDOFF_NAME}-minimal.zip" "$HANDOFF_NAME"
)

unzip -t "$ARCHIVE" >/dev/null

while IFS= read -r relative_path; do
  archive_path="$HANDOFF_NAME/$relative_path"

  if ! unzip -Z1 "$ARCHIVE" | grep -Fx "$archive_path" >/dev/null; then
    printf 'STOP: archive is missing %s\n' "$archive_path" >&2
    exit 1
  fi
done < "$HANDOFF_ROOT/FILE_MANIFEST.txt"

printf '\n=== CLAUDE HANDOFF CREATED AND VERIFIED ===\n'
printf 'Folder:  %s\n' "$HANDOFF_ROOT"
printf 'Archive: %s\n' "$ARCHIVE"
printf '\n=== ARCHIVE CONTENTS ===\n'
unzip -Z1 "$ARCHIVE" | sort
printf '\nUpload only this archive to Claude:\n%s\n' "$ARCHIVE"

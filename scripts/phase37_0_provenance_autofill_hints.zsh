#!/usr/bin/env zsh
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

: "${1:=PHASE37_RUN_VIEW_DEFINITION.sql}"
: "${2:=PHASE37_RUN_PROJECTION_CONTRACT.md}"

if [[ ! -f "$1" ]]; then
  echo "ERROR: missing view definition file: $1" >&2
  exit 2
fi

# Extract columns from the inventory table in PHASE37_RUN_PROJECTION_CONTRACT.md
# (fallback to information_schema via docker if needed is intentionally avoided here; docs-only)
cols="$(
  awk '
    /^\| [0-9]+ \| `[^`]+` \|/ {
      gsub(/^\|[ ]*[0-9]+[ ]*\|[ ]*`/,"",$0);
      gsub(/`[ ]*\|.*$/,"",$0);
      print $0;
    }
  ' "$2" 2>/dev/null || true
)"

if [[ -z "${cols:-}" ]]; then
  echo "ERROR: could not parse columns from $2 (inventory table). Ensure it contains the markdown table." >&2
  exit 2
fi

# Normalize the view definition into mostly-one-line SQL for easier grepping.
# Keep it deterministic and simple: collapse whitespace, keep commas.
norm="$(mktemp)"
tr '\n' ' ' < "$1" \
  | sed -E 's/[[:space:]]+/ /g; s/;[[:space:]]*$//;' \
  > "$norm"

# Try to isolate the SELECT list (best-effort): between "select " and " from "
# If that fails, we still grep the whole definition.
select_list="$(mktemp)"
if grep -qiE 'select .* from ' "$norm"; then
  sed -E 's/^.*[sS][eE][lL][eE][cC][tT] //; s/ [fF][rR][oO][mM] .*$/ /' "$norm" > "$select_list" || cp "$norm" "$select_list"
else
  cp "$norm" "$select_list"
fi

out="PHASE37_RUN_VIEW_PROVENANCE_HINTS.md"
cat > "$out" <<'MD'
# Phase 37 — run_view Provenance Hints (Auto-Extracted, Planning Only)

This file is **best-effort** automation to speed up filling:
- `PHASE37_RUN_VIEW_PROVENANCE_MATRIX.md`

It extracts the `SELECT ... AS <column>` expressions from the captured
`PHASE37_RUN_VIEW_DEFINITION.sql`. Treat as hints, not truth.

Canonical ordering key remains:
- `task_events.ts` ASC, tie-breaker `task_events.id` ASC

---

MD

# For each column, try to extract the nearest "AS col" expression snippet.
# We split by commas to approximate select items.
tmp_items="$(mktemp)"
tr ',' '\n' < "$select_list" \
  | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//;' \
  > "$tmp_items"

print -r -- "$cols" | while IFS= read -r col; do
  [[ -z "$col" ]] && continue
  echo "## $col" >> "$out"

  # Candidate lines that mention AS <col> or end with <col>
  hits="$(
    awk -v c="$col" '
      BEGIN { IGNORECASE=1; n=0 }
      $0 ~ ("[[:space:]]as[[:space:]]+" c "([[:space:]]|$)") { print; n++; next }
      $0 ~ ("(^|[[:space:]])" c "([[:space:]]|$)") { print; n++; next }
      END { }
    ' "$tmp_items" | sed -E 's/[[:space:]]+/ /g'
  )"

  if [[ -n "$hits" ]]; then
    echo "- Candidate expression(s):" >> "$out"
    echo "$hits" | head -n 3 | sed 's/^/  - `/' | sed 's/$/`/' >> "$out"
  else
    echo "- Candidate expression(s): *(none found via simple parse — inspect PHASE37_RUN_VIEW_DEFINITION.sql manually)*" >> "$out"
  fi

  cat >> "$out" <<'BLANK'

- Likely source(s):
- Notes:

BLANK
done

rm -f "$norm" "$select_list" "$tmp_items"
echo "Wrote: $out"

#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mkdir -p docs
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_identify_docs_volatile_writers_${STAMP}.md"

{
  echo "# Phase 487 Identify Docs Volatile Writers"
  echo
  echo "- Generated: $(date -Iseconds)"
  echo "- Repo root: $REPO_ROOT"
  echo "- Git branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "- Git commit: $(git rev-parse HEAD)"
  echo

  echo "## Goal"
  echo
  echo "Locate the single highest-confidence script or command path that writes volatile probe / recovery / live diagnostic outputs into versioned docs/."
  echo

  echo "## Exact docs write patterns (repo scan)"
  echo
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' \
      '(docs/[^"'"'"' )]+|> docs/|>> docs/|tee[[:space:]]+-a[[:space:]]+docs/|tee[[:space:]]+docs/|OUT=.*docs/|OUTPUT=.*docs/|LOG=.*docs/)' . \
      | sed 's/^/- /' || true
  else
    grep -RInE '(docs/[^"'"'"' )]+|> docs/|>> docs/|tee[[:space:]]+-a[[:space:]]+docs/|tee[[:space:]]+docs/|OUT=.*docs/|OUTPUT=.*docs/|LOG=.*docs/)' . \
      --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.next \
      | sed 's/^/- /' || true
  fi
  echo

  echo "## Phase 487-focused docs write patterns"
  echo
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' \
      '(phase487|probe|recovery|diagnostic|trace|live_probe|surface_probe|audit_output)' scripts app server src public . \
      2>/dev/null \
      | sed 's/^/- /' || true
  else
    grep -RInE '(phase487|probe|recovery|diagnostic|trace|live_probe|surface_probe|audit_output)' \
      scripts app server src public . \
      --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.next 2>/dev/null \
      | sed 's/^/- /' || true
  fi
  echo

  echo "## Shell/script append-style operators"
  echo
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' \
      '(>>|tee -a|appendFile|appendFileSync|createWriteStream)' scripts . \
      | sed 's/^/- /' || true
  else
    grep -RInE '(>>|tee -a|appendFile|appendFileSync|createWriteStream)' scripts . \
      --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.next \
      | sed 's/^/- /' || true
  fi
  echo

  echo "## Existing phase487 volatile docs candidates"
  echo
  find docs -maxdepth 1 -type f \
    \( -name 'phase487_*probe*' -o -name 'phase487_*recovery*' -o -name 'phase487_*diagnostic*' -o -name 'phase487_*trace*' -o -name 'phase487_*live_probe*' -o -name 'phase487_*audit_output*' \) \
    | sort \
    | sed 's/^/- /'
  echo

  echo "## Highest-confidence next target selection rule"
  echo
  echo "- Choose one writer path only."
  echo "- Prefer a script under scripts/_local or scripts/ that writes transient probe / recovery evidence into docs/."
  echo "- Prefer overwrite semantics over append semantics."
  echo "- Redirect transient output to a non-repo runtime path in the next mutation."
  echo "- Do not mutate backend, governance, approval, execution, or UI logic in the next step."
} > "$OUT"

echo "$OUT"

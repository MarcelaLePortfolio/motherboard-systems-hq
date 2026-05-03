#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mkdir -p docs

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_artifact_containment_audit_${STAMP}.md"

{
  echo "# Phase 487 Artifact Containment Audit"
  echo
  echo "- Generated: $(date -Iseconds)"
  echo "- Repo root: $REPO_ROOT"
  echo "- Git branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "- Git commit: $(git rev-parse HEAD)"
  echo

  echo "## Objective"
  echo
  echo "Create a read-only evidence snapshot of artifact growth risk before any containment mutation."
  echo

  echo "## Top 50 largest tracked files"
  echo
  git ls-files -z \
    | xargs -0 du -h 2>/dev/null \
    | sort -hr \
    | head -n 50 \
    | sed 's/^/- /'
  echo

  echo "## Top 50 largest files under repo root (excluding .git, node_modules, .next)"
  echo
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './.next' -prune -o \
    -type f -print0 \
    | xargs -0 du -h 2>/dev/null \
    | sort -hr \
    | head -n 50 \
    | sed 's/^/- /'
  echo

  echo "## Candidate append / artifact growth hotspots"
  echo
  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!.next/**' \
      '>>|appendFile|appendFileSync|createWriteStream|WriteStream|fs\.writeFile|tee -a|nohup .*>|logFile|\.log|artifacts?|diagnostics?|probe' . \
      | sed 's/^/- /' || true
  else
    grep -RInE '>>|appendFile|appendFileSync|createWriteStream|WriteStream|fs\.writeFile|tee -a|nohup .*>|logFile|\.log|artifacts?|diagnostics?|probe' . \
      --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.next \
      | sed 's/^/- /' || true
  fi
  echo

  echo "## Existing docs log-like files"
  echo
  find docs -type f \( -name '*.log' -o -name '*.txt' -o -name '*.jsonl' -o -name '*probe*' -o -name '*diagnostic*' -o -name '*artifact*' \) 2>/dev/null \
    | sort \
    | sed 's/^/- /' || true
  echo

  echo "## Git status"
  echo
  git status --short | sed 's/^/- /'
  echo

  echo "## Initial containment recommendation"
  echo
  echo "- Contain only after reviewing this report."
  echo "- First mutation should target a single highest-confidence append/growth path."
  echo "- Do not modify backend, governance, approval, or execution layers in containment step 1."
} > "$OUT"

echo "$OUT"

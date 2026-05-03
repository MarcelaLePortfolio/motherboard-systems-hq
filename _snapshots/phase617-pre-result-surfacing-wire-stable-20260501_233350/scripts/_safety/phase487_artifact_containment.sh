#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs"
REPORT_PATH="$DOCS_DIR/phase487_artifact_containment_report.txt"
EXTERNAL_ARTIFACT_ROOT="/tmp/motherboard-systems-hq-artifacts"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$DOCS_DIR"
mkdir -p "$EXTERNAL_ARTIFACT_ROOT"

cd "$REPO_ROOT"

{
  echo "PHASE 487 ARTIFACT CONTAINMENT REPORT"
  echo "Generated: $TIMESTAMP"
  echo "Repo: $REPO_ROOT"
  echo

  echo "1. CONTAINMENT POLICY"
  echo "- Large runtime artifacts must not live in the repo."
  echo "- Prefer overwrite (>) over append (>>)."
  echo "- Prefer sampled output over full dumps."
  echo "- Redirect heavy logs/traces/scans to: $EXTERNAL_ARTIFACT_ROOT"
  echo

  echo "2. LARGEST FILES IN REPO (TOP 40)"
  python3 - << 'PY'
import os

skip_dirs = {'.git', 'node_modules', '.next'}
files = []
for root, dirs, filenames in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in skip_dirs]
    for name in filenames:
        path = os.path.join(root, name)
        try:
            size = os.path.getsize(path)
        except OSError:
            continue
        files.append((size, path))
for size, path in sorted(files, reverse=True)[:40]:
    print(f"{size:12d} bytes  {path}")
PY
  echo

  echo "3. FILES OVER 50MB"
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
    -type f -size +50M -print \
    | sort || true
  echo

  echo "4. SUSPECT ARTIFACT FILES"
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
    -type f \
    \( \
      -iname '*.log' -o \
      -iname '*.trace' -o \
      -iname '*.scan' -o \
      -iname '*.out' -o \
      -iname '*.tmp' -o \
      -iname '*.dump' -o \
      -iname '*.diagnostic' \
    \) -print \
    | sort || true
  echo

  echo "5. DIRECTORY SIZE SNAPSHOT (TOP 30)"
  du -sh ./* ./.??* 2>/dev/null | sort -hr | head -30 || true
  echo

  echo "6. RECENTLY MODIFIED FILES > 5MB (LAST 24 HOURS)"
  find . \
    \( -path './.git' -o -path './node_modules' -o -path './.next' \) -prune -o \
    -type f -size +5M -mtime -1 -print \
    | sort || true
  echo

  echo "7. SAFE REDIRECTION TARGET"
  echo "$EXTERNAL_ARTIFACT_ROOT"
  echo

  echo "8. NEXT ACTIONS"
  echo "- Move heavy runtime outputs to $EXTERNAL_ARTIFACT_ROOT"
  echo "- Replace unsafe append loops with overwrite or capped rotation"
  echo "- Keep source-of-truth artifacts in docs/ only when small and bounded"
  echo "- Do not delete anything until the report is reviewed"
} > "$REPORT_PATH"

echo "Containment report written to: $REPORT_PATH"
echo "External artifact root prepared at: $EXTERNAL_ARTIFACT_ROOT"

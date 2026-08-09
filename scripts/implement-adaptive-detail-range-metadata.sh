#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT ADAPTIVE DETAIL — RANGE METADATA ==="

if [[ "$(git rev-parse --short HEAD)" != "2169c6bf" ]]; then
  echo "STOP: HEAD no longer matches inspected checkpoint 2169c6bf."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-adaptive-detail-range-metadata\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

python3 <<'PY'
from pathlib import Path

path = Path("server/matilda-project-context-retrieval.ts")
text = path.read_text()

old = '''function readBoundedExcerpt(
  absolutePath: string,
  lineNumber: number
): string | null {
  try {
    const stat = fs.statSync(absolutePath);

    if (!stat.isFile() || stat.size > 1_000_000) {
      return null;
    }

    const lines = fs.readFileSync(absolutePath, "utf8").split(/\\r?\\n/);
    const start = Math.max(0, lineNumber - 3);
    const end = Math.min(lines.length, lineNumber + 2);

    return lines
      .slice(start, end)
      .join("\\n")
      .trim()
      .slice(0, MAX_EXCERPT_CHARACTERS);
  } catch {
    return null;
  }
}
'''

new = '''interface MatildaBoundedExcerptReadResult {
  excerpt: string;
  metadata: {
    sourceStartLine: number;
    sourceEndLine: number;
    excerptTruncated: boolean;
  };
}

function readBoundedExcerpt(
  absolutePath: string,
  lineNumber: number
): MatildaBoundedExcerptReadResult | null {
  try {
    const stat = fs.statSync(absolutePath);

    if (!stat.isFile() || stat.size > 1_000_000) {
      return null;
    }

    const lines = fs.readFileSync(absolutePath, "utf8").split(/\\r?\\n/);
    const start = Math.max(0, lineNumber - 3);
    const end = Math.min(lines.length, lineNumber + 2);
    const boundedSource = lines
      .slice(start, end)
      .join("\\n")
      .trim();

    return {
      excerpt: boundedSource.slice(0, MAX_EXCERPT_CHARACTERS),
      metadata: {
        sourceStartLine: start + 1,
        sourceEndLine: end,
        excerptTruncated:
          boundedSource.length > MAX_EXCERPT_CHARACTERS,
      },
    };
  } catch {
    return null;
  }
}
'''

if old not in text:
    raise SystemExit(
        "STOP: readBoundedExcerpt implementation no longer matches inspected seam."
    )

text = text.replace(old, new, 1)

old = '''      const excerpt = readBoundedExcerpt(
        path.join(projectRoot, candidate.relativePath),
        candidate.lineNumber
      );

      if (!excerpt) {
        continue;
      }

      excerpts.push({
        projectId,
        relativePath: candidate.relativePath,
        lineNumber: candidate.lineNumber,
        excerpt,
        provenance: "git_tracked_project_file",
        authorityStatus: "candidate_evidence_not_authority",
      });
'''

new = '''      const boundedExcerpt = readBoundedExcerpt(
        path.join(projectRoot, candidate.relativePath),
        candidate.lineNumber
      );

      if (!boundedExcerpt) {
        continue;
      }

      excerpts.push({
        projectId,
        relativePath: candidate.relativePath,
        lineNumber: candidate.lineNumber,
        excerpt: boundedExcerpt.excerpt,
        provenance: "git_tracked_project_file",
        authorityStatus: "candidate_evidence_not_authority",
      });
'''

if old not in text:
    raise SystemExit(
        "STOP: excerpt construction path no longer matches inspected seam."
    )

path.write_text(text.replace(old, new, 1))
print("Implemented retrieval-internal bounded excerpt range metadata.")
PY

echo
echo "=== RETRIEVAL TESTS ==="
npx tsx --test server/matilda-project-context-retrieval.test.ts

echo
echo "=== CONVERSATION CONTEXT TESTS ==="
npx tsx --test server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_RANGE_METADATA_IMPLEMENTED"

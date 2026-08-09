#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — EXCERPT RANGE METADATA EXTENSION INVESTIGATION ==="
echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "PROTECTED DR: 20260808_231729"

echo
echo "=== PROJECT-CONTEXT EXCERPT CONTRACT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'MatildaProjectContextExcerpt|projectContextExcerpts' \
  server db scripts 2>/dev/null | head -n 160 || true

echo
echo "=== BOUNDED EXCERPT CONSTRUCTION ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'readBoundedExcerpt|MAX_EXCERPT_CHARACTERS|lineNumber - 3|lineNumber \+ 2|slice\(start, end\)' \
  server db scripts 2>/dev/null | head -n 160 || true

echo
echo "=== EXCERPT FIELD CONSUMERS ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  '\.relativePath|\.lineNumber|\.excerpt|provenance|authorityStatus' \
  server db scripts 2>/dev/null | \
  grep -E \
  'projectContext|ProjectContext|supportSource|evidence|Excerpt' | \
  head -n 220 || true

echo
echo "=== SUPPORT PROVENANCE CONTRACT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'project_context_excerpt|supportSourceReferences|evidenceSufficient' \
  server db scripts 2>/dev/null | head -n 220 || true

echo
echo "=== RANGE / TRUNCATION METADATA PRECEDENT ==="
grep -R -n \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E \
  'startLineNumber|endLineNumber|startLine|endLine|truncated|isTruncated|characterLimit|sourceRange' \
  server db scripts 2>/dev/null | head -n 160 || true

echo
echo "=== RELEVANT TEST SURFACE ==="
find server db scripts \
  -type f \
  \( -name '*project-context*test*' \
     -o -name '*support-source*test*' \
     -o -name '*structured-evidence*test*' \
     -o -name '*conversation-context*test*' \) \
  -print 2>/dev/null | sort

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_EXTENSION_INVESTIGATION_CAPTURED"
echo "NO_IMPLEMENTATION_AUTHORIZED"

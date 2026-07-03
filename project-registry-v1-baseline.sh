
#!/bin/bash

set -e

echo "=== PROJECT REGISTRY V1 BASELINE ==="

echo

echo "Current branch:"

git branch --show-current

echo

echo "Current HEAD:"

git log --oneline -1

echo

echo "Verifying clean working tree..."

git status --short

if [ -n "$(git status --porcelain)" ]; then

  echo

  echo "ERROR: Working tree is not clean."

  exit 1

fi

TAG="project-registry-v1-stable-$(date +%Y%m%d)"

if git rev-parse "$TAG" >/dev/null 2>&1; then

  echo "Tag already exists: $TAG"

else

  git tag -a "$TAG" -m "Project Registry V1 Stable Baseline"

  git push origin "$TAG"

fi

echo

echo "Baseline tag:"

git describe --tags --exact-match || true

echo

echo "Registry:"

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

echo

echo "STATUS: Project Registry V1 frozen."

echo "NEXT: Begin Phase V2 implementation from tagged baseline."


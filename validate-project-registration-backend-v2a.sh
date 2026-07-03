
#!/bin/bash

set -e

mkdir -p tmp/non-git-project-validation

mkdir -p tmp/git-project-validation

if [ ! -d tmp/git-project-validation/.git ]; then

  git init tmp/git-project-validation >/dev/null

fi

echo "=== Non-Git existing directory should fail ==="

curl -i -X POST http://localhost:3001/api/projects/register -H "Content-Type: application/json" -d '{"projectId":"non-git-validation-test","displayName":"Non Git Validation Test","projectRootPath":"tmp/non-git-project-validation","gitRepositoryReference":"tmp/non-git-project-validation"}'

echo

echo "=== Duplicate path should fail ==="

curl -i -X POST http://localhost:3001/api/projects/register -H "Content-Type: application/json" -d '{"projectId":"hq-duplicate-path-test","displayName":"HQ Duplicate Path Test","projectRootPath":".","gitRepositoryReference":"."}'

echo

echo "=== Valid Git directory should succeed ==="

curl -i -X POST http://localhost:3001/api/projects/register -H "Content-Type: application/json" -d '{"projectId":"git-validation-test","displayName":"Git Validation Test","projectRootPath":"tmp/git-project-validation","gitRepositoryReference":"tmp/git-project-validation"}'

echo

echo "=== Registry state ==="

curl -s http://localhost:3001/api/projects/registry | python3 -m json.tool

echo

git status



#!/bin/bash

set -euo pipefail

BAD_COMMIT="d29787eb"

echo "Reverting accidental bulk commit: $BAD_COMMIT"

git revert --no-edit "$BAD_COMMIT"

echo ""

echo "Post-revert status:"

git status --short

echo ""

echo "Pushing revert commit..."

git push



#!/bin/bash

set -euo pipefail

echo "===== PHASE 717 FORCE CLEAN DISCOVERY ARTIFACTS ====="

git revert --abort 2>/dev/null || true

git fetch origin dev

git reset --hard origin/dev

rm -f PHASE717_INSPECT_EXECUTION_SURFACES.sh PHASE717_FIX_INSPECTION_SCRIPT.sh PHASE717_TARGETED_DISCOVERY.sh PHASE717_TARGETED_DISCOVERY_RESULT.txt PHASE717_CLEAN_DISCOVERY_OUTPUT.sh PHASE717_RUN_BOUNDED_DISCOVERY.sh PHASE717_GIT_GREP_DISCOVERY.sh PHASE717_GIT_GREP_DISCOVERY_RESULT.txt PHASE717_EXECUTION_SURFACE_INSPECTION_RESULT.txt PHASE717_REVERT_BROKEN_DISCOVERY.sh PHASE717_ABORT_AND_CLEAN_DISCOVERY.sh

cat > PHASE717_DISCOVERY_RESET_NOTE.txt << 'EON'

PHASE 717 DISCOVERY RESET NOTE

The previous discovery-script corridor is closed.

Reason:

- multiple broad shell discovery scripts produced parsing errors or excessive output

- discovery artifacts are not part of the stable product surface

- next work should inspect exact files directly instead of committing broad search outputs

Next safe approach:

- do not commit discovery output

- inspect exact target files with direct sed/cat only

- make one code change at a time after exact file paths are known

- avoid broad search scripts unless run manually and not committed

EON

git add -A

git commit -m "Phase 717: clean failed discovery artifacts" || true

git push origin dev

git status --short

git log --oneline --decorate -5

echo "===== PHASE 717 FORCE CLEAN DISCOVERY ARTIFACTS COMPLETE ====="


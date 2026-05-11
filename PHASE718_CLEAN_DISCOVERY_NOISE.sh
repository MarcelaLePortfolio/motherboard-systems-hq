
#!/usr/bin/env bash

set -euo pipefail

rm -f PHASE718_MINIMAL_RENDERER_DISCOVERY.sh PHASE718_NARROW_RENDERER_DISCOVERY.sh PHASE718_QUIET_RENDERER_DISCOVERY.sh

echo "Remaining status:"

git status --short

git add -A

git commit -m "Phase 718: clean unused renderer discovery scripts"

git push origin dev


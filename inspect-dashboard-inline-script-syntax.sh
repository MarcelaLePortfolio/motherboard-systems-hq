
#!/usr/bin/env bash

set -euo pipefail

rm -rf .tmp-dashboard-inline-scripts

mkdir -p .tmp-dashboard-inline-scripts

python3 - << 'PY'

from pathlib import Path

import re

html = Path("public/dashboard.html").read_text()

out = Path(".tmp-dashboard-inline-scripts")

for idx, match in enumerate(re.finditer(r"<script([^>]*)>([\s\S]*?)</script>", html, re.I), start=1):

    attrs = match.group(1)

    body = match.group(2)

    start_line = html[:match.start()].count("\n") + 1

    if "src=" in attrs:

        continue

    path = out / f"inline-script-{idx:03d}-line-{start_line}.js"

    path.write_text(body.strip() + "\n")

    print(path)

PY

echo

echo "--- inline scripts extracted ---"

ls -lah .tmp-dashboard-inline-scripts || true

echo

echo "--- node syntax checks ---"

failed=0

for f in .tmp-dashboard-inline-scripts/*.js; do

  [ -e "$f" ] || continue

  echo "CHECK $f"

  if ! node --check "$f"; then

    failed=1

  fi

done

echo

echo "--- script/style boundary map ---"

grep -nE '<script|</script>|<style|</style>' public/dashboard.html > dashboard-script-style-boundary-map.txt

cat dashboard-script-style-boundary-map.txt

exit "$failed"


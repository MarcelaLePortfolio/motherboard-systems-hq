
#!/usr/bin/env bash

set -euo pipefail

grep -Ei "PHASE91|LIVE ROOT|EXACTLY MATCHES|DIFFERS FROM PHASE91|served dashboard|/dashboard|public/dashboard.html|public/index.html|authoritative|canonical|anchor|golden" intended-dashboard-authority-report.txt \

  > dashboard-authority-focused-summary.txt || true

echo "--- line count ---"

wc -l dashboard-authority-focused-summary.txt

echo

echo "--- strongest dashboard authority signals ---"

grep -Ei "LIVE ROOT|EXACTLY MATCHES|DIFFERS FROM PHASE91|served dashboard|app.get\\(\"/dashboard|public/dashboard.html|public/index.html|golden" dashboard-authority-focused-summary.txt | tail -120 || true

git add summarize-dashboard-authority.sh dashboard-authority-focused-summary.txt

git commit -m "Summarize dashboard authority signals"

git push


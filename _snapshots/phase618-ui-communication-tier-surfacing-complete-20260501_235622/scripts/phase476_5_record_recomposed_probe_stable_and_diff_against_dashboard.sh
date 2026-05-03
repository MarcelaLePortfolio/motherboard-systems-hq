#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase476_5_recomposed_probe_result.txt"
DIFF_OUT="docs/phase476_5_dashboard_vs_recomposed_diff.txt"

mkdir -p docs

cat > "$RESULT_OUT" <<'EOT'
PHASE 476.5 — RECOMPOSED PROBE RESULT
=====================================

RESULT:
RECOMPOSED_PROBE_STABLE

OPTIONAL_NOTE:
The recomposed full-body probe appears stable.
EOT

python3 <<'PY'
from pathlib import Path
import difflib
import re

dashboard = Path("public/dashboard.html").read_text().splitlines()
recomposed = Path("public/dashboard_recomposed_from_stable_quarters_probe.html").read_text().splitlines()
out = Path("docs/phase476_5_dashboard_vs_recomposed_diff.txt")

def summarize(lines):
    body_match = re.search(r"(?is)<body[^>]*>(.*)</body>", "\n".join(lines))
    return {
        "line_count": len(lines),
        "has_bundle_tag": any('bundle.js' in line and '<script' in line for line in lines),
        "stylesheet_count": sum(1 for line in lines if '<link' in line and 'stylesheet' in line),
        "inline_style_blocks": sum(1 for line in lines if '<style' in line),
        "body_len": len(body_match.group(1).splitlines()) if body_match else None,
    }

dash_summary = summarize(dashboard)
recomp_summary = summarize(recomposed)

diff = list(difflib.unified_diff(
    dashboard,
    recomposed,
    fromfile="public/dashboard.html",
    tofile="public/dashboard_recomposed_from_stable_quarters_probe.html",
    lineterm=""
))

with out.open("w") as f:
    f.write("PHASE 476.5 — DASHBOARD VS RECOMPOSED DIFF\n")
    f.write("==========================================\n\n")
    f.write("STEP 1 — Stable recomposed probe recorded\n")
    f.write("RECOMPOSED_PROBE_STABLE\n\n")
    f.write("STEP 2 — Structural summaries\n")
    f.write(f"dashboard_summary={dash_summary}\n")
    f.write(f"recomposed_summary={recomp_summary}\n\n")
    f.write("STEP 3 — Unified diff (first 400 lines)\n")
    for line in diff[:400]:
        f.write(line + "\n")
    f.write("\nSTEP 4 — Next-action interpretation\n")
    f.write("- If dashboard.html contains extra lines not present in the stable recomposed probe, those lines are the highest-confidence fault candidates.\n")
    f.write("- Next mutation should remove only the dashboard-only delta while preserving the stable recomposed shape.\n")
PY

echo "Wrote $RESULT_OUT"
sed -n '1,120p' "$RESULT_OUT"
echo
echo "Wrote $DIFF_OUT"
sed -n '1,260p' "$DIFF_OUT"

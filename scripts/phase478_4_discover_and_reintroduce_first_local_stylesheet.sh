#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak"
OUT="docs/phase478_4_discover_and_reintroduce_first_local_stylesheet.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re
import sys

target_path = Path("public/dashboard.html")
target = target_path.read_text()

candidate_sources = [
    Path("public/dashboard.html.phase476_6_pre_strip.bak"),
    Path("public/dashboard.html.phase477_8_pre_restore.bak"),
    Path("public/dashboard.html.phase478_1_pre_script_restore.bak"),
    Path("public/dashboard.html.phase477_6_pre_src_script_neutralization.bak"),
    Path("public/dashboard.html.phase477_4_pre_inline_script_neutralization.bak"),
]

local_links = []
seen = set()

link_pattern = re.compile(r'(?im)^\s*<link[^>]*href=["\']([^"\']+)["\'][^>]*>\s*$')

for source in candidate_sources:
    if not source.exists():
        continue
    text = source.read_text()
    for m in link_pattern.finditer(text):
        full_tag = m.group(0).strip()
        href = m.group(1).strip()
        href_lower = href.lower()

        if "stylesheet" not in full_tag.lower():
            continue
        if "tailwind" in href_lower:
            continue
        if href_lower.startswith("http://") or href_lower.startswith("https://"):
            continue
        if "/css/" in href_lower or href_lower.startswith("css/"):
            key = (href_lower, full_tag)
            if key not in seen:
                seen.add(key)
                local_links.append({
                    "source": str(source),
                    "href": href,
                    "tag": full_tag,
                })

preferred = None
for item in local_links:
    if "dashboard.css" in item["href"].lower():
        preferred = item
        break

if preferred is None and local_links:
    preferred = local_links[0]

report_lines = []
report_lines.append("PHASE 478.4 — DISCOVER AND REINTRODUCE FIRST LOCAL STYLESHEET")
report_lines.append("============================================================")
report_lines.append("")
report_lines.append(f"candidate_source_count={len(candidate_sources)}")
report_lines.append(f"discovered_local_stylesheet_count={len(local_links)}")
report_lines.append("")
report_lines.append("DISCOVERED LOCAL STYLESHEETS")
for item in local_links:
    report_lines.append(f"- source={item['source']} href={item['href']}")
report_lines.append("")

if preferred is None:
    report_lines.append("ERROR: no local stylesheet tags discovered in candidate backups")
    Path("docs/phase478_4_discover_and_reintroduce_first_local_stylesheet.txt").write_text("\n".join(report_lines) + "\n")
    print("ERROR: no local stylesheet tags discovered in candidate backups", file=sys.stderr)
    sys.exit(1)

report_lines.append(f"SELECTED_SOURCE={preferred['source']}")
report_lines.append(f"SELECTED_HREF={preferred['href']}")
report_lines.append(f"SELECTED_TAG={preferred['tag']}")
report_lines.append("")

if preferred["href"] in target:
    report_lines.append("LOCAL_STYLESHEET_ALREADY_PRESENT=1")
else:
    head_close = re.search(r'(?i)</head>', target)
    if not head_close:
        report_lines.append("ERROR: could not find </head> insertion point")
        Path("docs/phase478_4_discover_and_reintroduce_first_local_stylesheet.txt").write_text("\n".join(report_lines) + "\n")
        print("ERROR: could not find </head> insertion point", file=sys.stderr)
        sys.exit(1)

    insert_block = "\n" + preferred["tag"] + "\n"
    target = target[:head_close.start()] + insert_block + target[head_close.start():]
    target_path.write_text(target)

    report_lines.append("LOCAL_STYLESHEET_REINTRODUCED=1")
    report_lines.append(f"NEW_LEN={len(target)}")

Path("docs/phase478_4_discover_and_reintroduce_first_local_stylesheet.txt").write_text("\n".join(report_lines) + "\n")
print(f"SELECTED_HREF={preferred['href']}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 478.4 — DISCOVER AND REINTRODUCE FIRST LOCAL STYLESHEET"
  echo "============================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Backup created"
  echo "$BACKUP"
  echo
  echo "STEP 2 — Discovery report"
  sed -n '1,220p' "$OUT"
  echo
  echo "STEP 3 — Confirm active stylesheet lines"
  rg -n 'tailwind\.min\.css|<link[^>]*href=' "$TARGET" || true
  echo
  echo "STEP 4 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo
  echo "STEP 5 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo
  echo "STEP 6 — Wait for host port 8080 readiness"
  READY=0
  for i in {1..20}; do
    if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
      READY=1
      echo "READY_ON_8080 attempt=$i"
      break
    fi
    sleep 1
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo
  echo "STEP 7 — Probe dashboard route"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "STEP 8 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo
  echo "STEP 9 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: SINGLE_LOCAL_STYLESHEET_REINTRODUCED"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • SINGLE_LOCAL_CSS_STABLE"
  echo "  • SINGLE_LOCAL_CSS_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} >> "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"

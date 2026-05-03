#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase478_5_pre_repo_stylesheet_restore.bak"
OUT="docs/phase478_5_search_repo_for_original_stylesheet_tags_and_restore_first_match.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re
import sys

target_path = Path("public/dashboard.html")
target = target_path.read_text()

# Search broader repo history/backup artifacts for original local stylesheet tags
candidate_paths = []
for pattern in [
    "public/dashboard*.bak*",
    "public/*.bak*",
    "public/*backup*",
    "public/*.html",
    "docs/**/*.txt",
    "docs/**/*.md",
]:
    candidate_paths.extend(Path(".").glob(pattern))

seen_paths = set()
ordered_paths = []
for p in candidate_paths:
    s = str(p)
    if s not in seen_paths and p.is_file():
        seen_paths.add(s)
        ordered_paths.append(p)

local_link_pattern = re.compile(
    r'(?im)^\s*(<link[^>]*rel=["\']stylesheet["\'][^>]*href=["\']([^"\']+)["\'][^>]*>|<link[^>]*href=["\']([^"\']+)["\'][^>]*rel=["\']stylesheet["\'][^>]*>)\s*$'
)

discovered = []
seen = set()

for path in ordered_paths:
    try:
        text = path.read_text(errors="ignore")
    except Exception:
        continue

    for m in local_link_pattern.finditer(text):
        tag = m.group(1).strip()
        href = (m.group(2) or m.group(3) or "").strip()
        href_lower = href.lower()

        if "tailwind" in href_lower:
            continue
        if href_lower.startswith("http://") or href_lower.startswith("https://"):
            continue
        if not (href_lower.startswith("css/") or href_lower.startswith("/css/")):
            continue

        key = (href_lower, tag)
        if key in seen:
            continue
        seen.add(key)
        discovered.append({"path": str(path), "href": href, "tag": tag})

preferred = None
for item in discovered:
    if "dashboard.css" in item["href"].lower():
        preferred = item
        break
if preferred is None and discovered:
    preferred = discovered[0]

report = []
report.append("PHASE 478.5 — SEARCH REPO FOR ORIGINAL STYLESHEET TAGS AND RESTORE FIRST MATCH")
report.append("=========================================================================")
report.append("")
report.append(f"searched_file_count={len(ordered_paths)}")
report.append(f"discovered_local_stylesheet_count={len(discovered)}")
report.append("")
report.append("DISCOVERED LOCAL STYLESHEETS")
for item in discovered[:80]:
    report.append(f"- path={item['path']} href={item['href']}")
report.append("")

if preferred is None:
    report.append("ERROR: no local stylesheet tags discovered anywhere in searched repo files")
    Path("docs/phase478_5_search_repo_for_original_stylesheet_tags_and_restore_first_match.txt").write_text("\n".join(report) + "\n")
    print("ERROR: no local stylesheet tags discovered anywhere in searched repo files", file=sys.stderr)
    sys.exit(1)

report.append(f"SELECTED_PATH={preferred['path']}")
report.append(f"SELECTED_HREF={preferred['href']}")
report.append(f"SELECTED_TAG={preferred['tag']}")
report.append("")

if preferred["href"] in target:
    report.append("LOCAL_STYLESHEET_ALREADY_PRESENT=1")
else:
    head_close = re.search(r'(?i)</head>', target)
    if not head_close:
        report.append("ERROR: could not find </head> insertion point")
        Path("docs/phase478_5_search_repo_for_original_stylesheet_tags_and_restore_first_match.txt").write_text("\n".join(report) + "\n")
        print("ERROR: could not find </head> insertion point", file=sys.stderr)
        sys.exit(1)

    target = target[:head_close.start()] + preferred["tag"] + "\n" + target[head_close.start():]
    target_path.write_text(target)
    report.append("LOCAL_STYLESHEET_REINTRODUCED=1")
    report.append(f"NEW_LEN={len(target)}")

Path("docs/phase478_5_search_repo_for_original_stylesheet_tags_and_restore_first_match.txt").write_text("\n".join(report) + "\n")
print(f"SELECTED_HREF={preferred['href']}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo
  echo "STEP 1 — Backup created"
  echo "$BACKUP"
  echo
  echo "STEP 2 — Discovery report"
  sed -n '1,240p' "$OUT"
  echo
  echo "STEP 3 — Confirm active stylesheet lines"
  rg -n 'tailwind\.min\.css|dashboard\.css|broadcast\.css|agent-status-row\.css|matilda-chat\.css|phase61_' "$TARGET" || true
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
    echo "CLASSIFICATION: REPO_DISCOVERED_LOCAL_STYLESHEET_REINTRODUCED"
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
sed -n '1,300p' "$OUT"


#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE530_BRIDGE_LINEAGE_INSPECTION.txt"

PREVIEW="_dashboard_candidate_previews/phase530-bridge-lineage"

mkdir -p "$PREVIEW"

{

  echo "===== PHASE530 BRIDGE LINEAGE INSPECTION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== CURRENT BRIDGE FILE ====="

  if [ -f public/js/phase530_visible_panels_bridge.js ]; then

    wc -c public/js/phase530_visible_panels_bridge.js

    grep -ni "artifact preview\|preview\|recent tasks\|agent pool\|retry\|requeue\|phase719\|render\|sanitize\|modal\|visual" public/js/phase530_visible_panels_bridge.js | head -120 || true

  else

    echo "Current bridge file missing."

  fi

  echo

  echo "===== RIO DRIVE BRIDGE CANDIDATES ====="

  python3 - << 'PY'

from pathlib import Path

import shutil

import subprocess

roots = [

    Path("/Volumes/Rio Drive/Motherboard_Systems_HQ"),

    Path("/Volumes/Rio Drive/Motherboard_Storage"),

]

markers = [

    "artifact preview",

    "Preview",

    "Recent Tasks",

    "Agent Pool",

    "Retry",

    "Requeue",

    "phase719",

    "phase530",

    "visible_panels_bridge",

    "render",

    "sanitize",

    "modal",

    "visual",

]

out = Path("_dashboard_candidate_previews/phase530-bridge-lineage")

out.mkdir(parents=True, exist_ok=True)

candidates = []

for root in roots:

    if not root.exists():

        continue

    for path in root.rglob("phase530_visible_panels_bridge*.js"):

        try:

            text = path.read_text(errors="ignore")

            score = sum(text.lower().count(m.lower()) for m in markers)

            candidates.append((path.stat().st_mtime, score, path.stat().st_size, path))

        except Exception:

            pass

candidates.sort(key=lambda item: (item[0], item[1], item[2]), reverse=True)

print("candidate_count=", len(candidates))

print()

for i, (mtime, score, size, path) in enumerate(candidates[:20], start=1):

    safe = f"{i:02d}-" + str(path).replace("/Volumes/Rio Drive/", "").replace("/", "__")

    dst = out / safe

    shutil.copy2(path, dst)

    print(f"{i:02d}: {path}")

    print(f"mtime: {mtime}")

    print(f"size: {size}")

    print(f"score: {score}")

    print(f"copy: {dst}")

    print()

PY

  echo

  echo "===== CURRENT VS TOP RIO CANDIDATE DIFFS ====="

  python3 - << 'PY'

from pathlib import Path

import subprocess

current = Path("public/js/phase530_visible_panels_bridge.js")

preview = Path("_dashboard_candidate_previews/phase530-bridge-lineage")

if not current.exists():

    print("Current bridge file missing; cannot diff.")

    raise SystemExit(0)

candidates = sorted(preview.glob("*.js"))[:8]

for candidate in candidates:

    print(f"--- DIFF AGAINST {candidate} ---")

    result = subprocess.run(

        ["diff", "-u", str(current), str(candidate)],

        text=True,

        stdout=subprocess.PIPE,

        stderr=subprocess.STDOUT,

    )

    lines = result.stdout.splitlines()

    if not lines:

        print("No diff.")

    else:

        print("\n".join(lines[:220]))

        if len(lines) > 220:

            print(f"... truncated {len(lines) - 220} more diff lines ...")

    print()

PY

  echo

  echo "===== SAFE NEXT ACTION ====="

  echo "Review the copied bridge candidates and diffs."

  echo "Do not restore yet; select the bridge file whose behavior matches the remembered dashboard."

} | tee "$REPORT"

git add inspect-phase530-bridge-lineage.sh "$REPORT" "$PREVIEW" || true

git commit -m "Inspect phase530 bridge lineage candidates" || true

git push


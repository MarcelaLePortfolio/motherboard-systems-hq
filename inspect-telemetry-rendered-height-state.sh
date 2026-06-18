
#!/usr/bin/env bash

set -euo pipefail

REPORT="telemetry-rendered-height-state-report.txt"

{

  echo "TELEMETRY RENDERED HEIGHT STATE REPORT"

  echo

  echo "--- current head ---"

  git log --oneline -6

  echo

  echo "--- local CSS rule currently applied ---"

  cat public/css/phase492_telemetry_equal_height_scroll.css

  echo

  echo "--- served asset confirms css load ---"

  curl -sS http://localhost:8080/dashboard.html | grep -nE 'phase492_telemetry_equal_height_scroll|phase61_tabs_observational_workspace|phase61_workspace_consolidation' || true

  echo

  echo "--- browser-side check instructions ---"

  cat << 'NOTE'

Open DevTools Console on http://localhost:8080/dashboard.html and paste:

(() => {

  const ids = [

    "operator-workspace-card",

    "observational-workspace-card",

    "operator-panels",

    "observational-panels",

    "recent-tasks-card",

    "task-events-card",

    "obs-panel-recent",

    "obs-panel-events"

  ];

  return ids.map((id) => {

    const el = document.getElementById(id);

    if (!el) return { id, missing: true };

    const r = el.getBoundingClientRect();

    const cs = getComputedStyle(el);

    return {

      id,

      height: Math.round(r.height),

      scrollHeight: el.scrollHeight,

      clientHeight: el.clientHeight,

      overflowY: cs.overflowY,

      display: cs.display,

      flex: cs.flex,

      hidden: el.hidden,

      classes: el.className

    };

  });

})();

Paste the returned object back here.

NOTE

} | tee "$REPORT"

cat > telemetry-height-hypothesis-reset.txt << 'NOTE'

TELEMETRY HEIGHT HYPOTHESIS RESET

Finding Status: ACTIVE

The first equal-height/scroll CSS did not produce the intended visible result.

Next safe action:

Inspect computed browser layout values before applying another CSS patch.

NOTE

git add inspect-telemetry-rendered-height-state.sh telemetry-rendered-height-state-report.txt telemetry-height-hypothesis-reset.txt

git commit -m "Inspect telemetry rendered height state" || true

git push


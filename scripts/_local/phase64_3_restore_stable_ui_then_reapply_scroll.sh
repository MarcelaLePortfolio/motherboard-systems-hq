#!/usr/bin/env bash
set -euo pipefail

BASE_COMMIT="${1:-7bcfcded}"

git restore --source="$BASE_COMMIT" -- public/dashboard.html public/js/phase61_recent_history_wire.js

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

marker_start = "/* Phase 64.3 telemetry fixed-height scroll enforcement */"
marker_end = "/* /Phase 64.3 telemetry fixed-height scroll enforcement */"

css_block = """
    /* Phase 64.3 telemetry fixed-height scroll enforcement */
    #phase61-workspace-grid {
      align-items: stretch;
    }

    #phase61-operator-column,
    #phase61-telemetry-column {
      min-height: 0;
    }

    #operator-workspace-card,
    #observational-workspace-card {
      height: 100%;
      min-height: 0;
    }

    #observational-workspace-card {
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }

    #observational-panels {
      flex: 1 1 auto;
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #observational-panels > .obs-panel {
      flex: 1 1 auto;
      min-height: 0;
    }

    #obs-panel-recent,
    #obs-panel-activity {
      min-height: 0;
    }

    #recent-tasks-card,
    #task-activity-card {
      height: 100%;
      min-height: 0;
      overflow: hidden;
    }

    [data-phase61-shell="recent"],
    [data-phase61-shell="history"] {
      height: 100%;
      min-height: 0;
      overflow: hidden;
    }

    [data-phase61-list="recent"],
    [data-phase61-list="history"] {
      flex: 1 1 auto;
      min-height: 0;
      overflow-y: auto;
      overflow-x: hidden;
    }

    @media (max-width: 1023px) {
      #operator-workspace-card,
      #observational-workspace-card,
      #recent-tasks-card,
      #task-activity-card,
      [data-phase61-shell="recent"],
      [data-phase61-shell="history"],
      [data-phase61-list="recent"],
      [data-phase61-list="history"] {
        height: auto;
        min-height: auto;
        overflow: visible;
      }
    }
    /* /Phase 64.3 telemetry fixed-height scroll enforcement */
"""

if marker_start in text and marker_end in text:
    start = text.index(marker_start)
    end = text.index(marker_end) + len(marker_end)
    text = text[:start] + css_block.strip("\n") + text[end:]
else:
    anchor = """
    @media (max-width: 920px) {
      .task-events-panel .task-event,
      [data-phase61-task-events] .task-event,
      [data-tab-panel="task-events"] .task-event,
      #task-events-panel .task-event,
      #task-events .task-event,
      .task-events .task-event,
      .task-events-panel li,
      [data-phase61-task-events] li,
      [data-tab-panel="task-events"] li,
      #task-events-panel li,
      #task-events li,
      .task-events li {
        grid-template-columns: 1fr;
        gap: 4px;
      }
    }
"""
    if anchor not in text:
        raise SystemExit("required CSS anchor not found in public/dashboard.html")
    text = text.replace(anchor, css_block + "\n\n" + anchor, 1)

if text == original:
    raise SystemExit("no CSS changes applied")

path.write_text(text)
print("patched public/dashboard.html")
PY

echo "restored UI baseline from $BASE_COMMIT and reapplied scroll-only CSS"

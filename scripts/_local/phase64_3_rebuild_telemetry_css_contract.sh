#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

path = Path("public/dashboard.html")
original = path.read_text()
text = original

start_marker = "    /* Phase 64.3 telemetry fixed-height scroll enforcement */"
end_marker = "    /* /Phase 64.3 telemetry fixed-height scroll enforcement */"

css_block = """    /* Phase 64.3 telemetry fixed-height scroll enforcement */
    #phase61-workspace-grid {
      align-items: stretch;
    }

    #phase61-operator-column,
    #phase61-telemetry-column {
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #operator-workspace-card,
    #observational-workspace-card {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
    }

    #operator-panels,
    #observational-panels {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      position: relative;
    }

    #operator-panels > [data-workspace-panel],
    #observational-panels > [data-workspace-panel] {
      min-height: 0;
    }

    #operator-panels > [data-workspace-panel][hidden],
    #observational-panels > [data-workspace-panel][hidden] {
      display: none !important;
    }

    #operator-panels > [data-workspace-panel].active:not([hidden]),
    #observational-panels > [data-workspace-panel].active:not([hidden]) {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
    }

    #recent-tasks-card,
    #task-activity-card,
    #task-events-card {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
    }

    #recent-tasks-card,
    #task-activity-card {
      overflow: hidden;
    }

    #task-events-card,
    #mb-task-events-panel-anchor {
      min-height: 0;
      flex: 1 1 auto;
      height: 100%;
    }

    #mb-task-events-panel-anchor {
      overflow: hidden;
    }

    [data-phase61-shell="recent"],
    [data-phase61-shell="history"] {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      overflow: hidden;
    }

    [data-phase61-list="recent"],
    [data-phase61-list="history"] {
      flex: 1 1 auto;
      min-height: 0;
      overflow-y: auto;
      overflow-x: hidden;
      padding-right: 4px;
    }

    @media (max-width: 1023px) {
      #operator-workspace-card,
      #observational-workspace-card,
      #operator-panels,
      #observational-panels,
      #operator-panels > [data-workspace-panel].active:not([hidden]),
      #observational-panels > [data-workspace-panel].active:not([hidden]),
      #recent-tasks-card,
      #task-activity-card,
      #task-events-card,
      #mb-task-events-panel-anchor,
      [data-phase61-shell="recent"],
      [data-phase61-shell="history"],
      [data-phase61-list="recent"],
      [data-phase61-list="history"] {
        height: auto;
        min-height: auto;
        max-height: none;
      }

      [data-phase61-list="recent"],
      [data-phase61-list="history"],
      #mb-task-events-panel-anchor {
        overflow: visible;
      }
    }
    /* /Phase 64.3 telemetry fixed-height scroll enforcement */"""

if start_marker in text and end_marker in text:
    start = text.index(start_marker)
    end = text.index(end_marker) + len(end_marker)
    text = text[:start] + css_block + text[end:]
else:
    raise SystemExit("phase64.3 css block markers not found in public/dashboard.html")

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/dashboard.html")
PY

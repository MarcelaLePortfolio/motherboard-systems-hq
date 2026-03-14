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
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #operator-panels,
    #observational-panels {
      flex: 1 1 auto;
      min-height: 0;
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
    }

    #op-panel-chat.active:not([hidden]),
    #op-panel-delegation.active:not([hidden]),
    #obs-panel-recent.active:not([hidden]),
    #obs-panel-activity.active:not([hidden]),
    #obs-panel-events.active:not([hidden]) {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
    }

    #recent-tasks-card,
    #task-activity-card,
    #task-events-card {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
      overflow: hidden;
    }

    [data-phase61-shell="recent"],
    [data-phase61-shell="history"] {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
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
      #operator-panels > [data-workspace-panel].active:not([hidden]),
      #observational-panels > [data-workspace-panel].active:not([hidden]),
      #op-panel-chat.active:not([hidden]),
      #op-panel-delegation.active:not([hidden]),
      #obs-panel-recent.active:not([hidden]),
      #obs-panel-activity.active:not([hidden]),
      #obs-panel-events.active:not([hidden]),
      #recent-tasks-card,
      #task-activity-card,
      #task-events-card,
      [data-phase61-shell="recent"],
      [data-phase61-shell="history"],
      [data-phase61-list="recent"],
      [data-phase61-list="history"] {
        height: auto;
        min-height: auto;
        max-height: none;
      }

      [data-phase61-list="recent"],
      [data-phase61-list="history"] {
        overflow: visible;
      }
    }
    /* /Phase 64.3 telemetry fixed-height scroll enforcement */"""

if start_marker in text and end_marker in text:
    start = text.index(start_marker)
    end = text.index(end_marker) + len(end_marker)
    text = text[:start] + css_block + text[end:]
else:
    anchor = """    @media (max-width: 920px) {
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
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/dashboard.html")
PY

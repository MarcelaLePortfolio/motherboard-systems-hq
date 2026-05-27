#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

start_marker = "/* Phase 64.3 telemetry fixed-height scroll enforcement */"
end_marker = "/* /Phase 64.3 telemetry fixed-height scroll enforcement */"

css_block = """
    /* Phase 64.3 telemetry fixed-height scroll enforcement */
    #phase61-workspace-shell {
      min-height: 0;
    }

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
      height: clamp(520px, 62vh, 720px);
      min-height: clamp(520px, 62vh, 720px);
      max-height: clamp(520px, 62vh, 720px);
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    #operator-panels,
    #observational-panels,
    #op-panel-chat,
    #op-panel-delegation,
    #obs-panel-recent,
    #obs-panel-activity,
    #obs-panel-events {
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    #recent-tasks-card,
    #task-activity-card,
    #task-events-card {
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    #tasks-widget,
    #task-activity-graph,
    #mb-task-events-panel-anchor {
      min-height: 0;
    }

    [data-phase61-shell="recent"],
    [data-phase61-shell="history"] {
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    [data-phase61-list="recent"],
    [data-phase61-list="history"] {
      flex: 1 1 auto;
      min-height: 0;
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
      padding-right: 4px;
    }

    @media (max-width: 1023px) {
      #operator-workspace-card,
      #observational-workspace-card {
        height: auto;
        min-height: auto;
        max-height: none;
      }

      #operator-panels,
      #observational-panels,
      #op-panel-chat,
      #op-panel-delegation,
      #obs-panel-recent,
      #obs-panel-activity,
      #obs-panel-events,
      #recent-tasks-card,
      #task-activity-card,
      #task-events-card,
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

if start_marker not in text or end_marker not in text:
    raise SystemExit("phase64.3 css block markers not found in public/dashboard.html")

start = text.index(start_marker)
end = text.index(end_marker) + len(end_marker)
text = text[:start] + css_block + text[end:]

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/dashboard.html")
PY

#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

block_start = "    /* Phase 64.3 telemetry fixed-height scroll enforcement */"
block_end = "    /* /Phase 64.3 telemetry fixed-height scroll enforcement */"

css_block = """
    /* Phase 64.3 telemetry fixed-height scroll enforcement */
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
      height: 100%;
      min-height: 0;
      display: flex;
      flex-direction: column;
    }

    #operator-panels,
    #observational-panels,
    #obs-panel-recent,
    #obs-panel-activity,
    #obs-panel-events,
    #op-panel-chat,
    #op-panel-delegation {
      flex: 1 1 auto;
      min-height: 0;
    }

    #recent-tasks-card,
    #task-activity-card,
    #task-events-card,
    #matilda-chat-card,
    #delegation-card {
      height: 100%;
      min-height: 0;
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }

    #recent-tasks-card > [data-phase61-shell],
    #task-activity-card > [data-phase61-shell],
    #recent-tasks-card > #tasks-widget,
    #task-activity-card > canvas,
    #task-activity-card > div,
    #task-events-card > #mb-task-events-panel-anchor {
      flex: 1 1 auto;
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
      #phase61-operator-column,
      #phase61-telemetry-column,
      #operator-workspace-card,
      #observational-workspace-card,
      #recent-tasks-card,
      #task-activity-card,
      #task-events-card,
      #matilda-chat-card,
      #delegation-card {
        height: auto;
        min-height: 0;
      }

      [data-phase61-shell="recent"],
      [data-phase61-shell="history"],
      [data-phase61-list="recent"],
      [data-phase61-list="history"] {
        height: auto;
        overflow: visible;
      }
    }
    /* /Phase 64.3 telemetry fixed-height scroll enforcement */
"""

if block_start in text and block_end in text:
    start = text.index(block_start)
    end = text.index(block_end) + len(block_end)
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
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/dashboard.html")
PY
